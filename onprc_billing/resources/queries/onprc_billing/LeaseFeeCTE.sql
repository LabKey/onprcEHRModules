PARAMETERS (StartDate TIMESTAMP, EndDate TIMESTAMP)

-- ========================================================
-- Revised Lease Fee CTE Query - LabKey SQL Compatible
-- Date: 2025-11-24 (reviewed/cleaned)
-- 2025-12-01 Final testing complete deploying to test instance for review
-- ========================================================
WITH
-- ========================================================
-- 1) Base assignments in date range
-- ========================================================
assignments AS (
    SELECT
        a.Id,
        -- create an identifier as assignment ID
        a.lsid AS assignmentId,
        a.date      AS assignmentDate,
        a.enddate   AS assignmentEndDate,
        a.project,

        -- Resource code from resourceAssigned (latest by date if multiple)
      (Select r.project.displayName from study.resourceAssigned r where r.id = a.id and r.project.enddate is Null) as resourceCode,

        a.assignCondition,
        a.releaseCondition,
        a.projectedRelease,
        a.projectedReleaseCondition,

  --Create a looklup for is a research project
       Case when a.id in (Select ra.id from study.researchAssigned ra where ra.id = a.id) then 1
           Else 0
           End as isResearchAssignment,

        -- dam of infant, if applicable
       (
            SELECT b.dam
            FROM study.birth b
            WHERE b.id = a.id
        ) AS damId,

        a.container
    FROM study.assignment a
    WHERE a.date >= StartDate
      AND a.date <  EndDate
),

-- ========================================================
-- 2) Animal age / infant vs adult
-- ========================================================
age_at_assignment AS (
    SELECT
        aa.Id,
        aa.assignmentId,
        aa.assignmentDate,
        aa.assignmentEndDate,
        aa.project,
        aa.resourceCode,
        aa.assignCondition,
        aa.releaseCondition,
        aa.projectedRelease,
        aa.damId,
        aa.isResearchAssignment,
        aa.container,
        d.birth,
        d.gender AS sex,

        -- Age in days
        TIMESTAMPDIFF('SQL_TSI_DAY', d.birth, aa.assignmentDate) AS ageDays,

        -- Infant flag: <= 1 year old at assignment
        CASE
            WHEN TIMESTAMPDIFF('SQL_TSI_YEAR', d.birth, aa.assignmentDate) <= 1 THEN 1
            ELSE 0
        END AS isInfant,

        -- Using projected release condition as terminal flag
        CASE
            WHEN aa.projectedReleaseCondition IN (206, 207) THEN 1
            ELSE 0
        END AS isTerminalAssignment
    FROM assignments aa
    LEFT JOIN study.demographics d
        ON d.Id = aa.Id
),

-- ========================================================
-- 3) PI purchase flag (for research assignments)
-- ========================================================
pi_purchase AS (
    SELECT DISTINCT
        f.Id,
        f.value,
        1 AS hasPIPurchase
    FROM study.flags f
    WHERE f.flag.value = 'PI Purchased NHP'
      -- AND f.isActive = true  -- uncomment if isActive exists and should filter
),

assign_with_pi AS (
    SELECT
        a.*,
        p.value,
        COALESCE(p.hasPIPurchase, 0) AS hasPIPurchase
    FROM age_at_assignment a
    LEFT JOIN pi_purchase p
        ON a.Id = p.Id
),

-- ========================================================
-- 4) Assignment length & condition change
-- ========================================================
assignment_length AS (
    SELECT
        a.*,
        TIMESTAMPDIFF(
            'SQL_TSI_DAY',
            a.assignmentDate,
            COALESCE(a.projectedRelease, a.assignmentEndDate)
        ) AS assignmentDays,

        CASE
            WHEN a.assignCondition = a.releaseCondition
                 OR a.releaseCondition IS NULL
                THEN 0
            ELSE 1
        END AS hasConditionChange
    FROM assign_with_pi a
),

-- ========================================================
-- 5) Resource type classification
-- ========================================================
resource_type AS (
    SELECT
        a.*,
        CASE
            WHEN a.resourceCode = '0300'     THEN 'TMB'
            WHEN a.resourceCode = '0456'     THEN 'AGING'
            WHEN a.resourceCode = '0833'     THEN 'OBESE'
            WHEN a.resourceCode = '0492-03'  THEN 'SPF9'
            WHEN a.resourceCode = '1092-50'  THEN 'AMR'
            WHEN a.resourceCode = '0492'     THEN 'COLONY'
            WHEN a.resourceCode = '0492-02'  THEN 'U42'
            WHEN a.resourceCode = '0492-45'  THEN 'JMR'
            ELSE 'OTHER'
        END AS resourceGroup
    FROM assignment_length a
),

-- ========================================================
-- 6) Dam/resource match (for infant/resource rules)
--    Map damId -> damResourceCode
-- ========================================================
dam_resource AS (
    SELECT DISTINCT
        r.damId,
        r.resourceCode AS damResourceCode
    FROM resource_type r
    WHERE r.damId IS NOT NULL
),

with_dam_match AS (
    SELECT
        a.*,
        CASE
            WHEN a.isInfant = 1
                 AND dr.damResourceCode = a.resourceCode
                THEN 1
            ELSE 0
        END AS infantSameDamResource
    FROM resource_type a
    LEFT JOIN dam_resource dr
        ON dr.damId = a.damId
),

-- ========================================================
-- 7) Determine lease type (core rule engine)
-- ========================================================
lease_type AS (
    SELECT
        a.*,

        CASE
            -- 1) Resource assignments
            WHEN a.isResearchAssignment = 0 THEN
                CASE
                    -- 1.1 Infant, dam in same resource → no lease
                    WHEN a.isInfant = 1
                         AND a.infantSameDamResource = 1
                        THEN 'NONE'

                    -- 1.2 TMB (0300)
                    WHEN a.resourceGroup = 'TMB' THEN
                        CASE
                            -- Example dam logic
                            WHEN a.isInfant = 0
                                 AND a.sex = 'F'
                                THEN 'TMB_LEASE'

                            -- infant from assigned TMB dam → no lease
                            WHEN a.isInfant = 1
                                 AND a.infantSameDamResource = 1
                                THEN 'NONE'

                            -- infant from unassigned TMB dam → P51 lease
                            WHEN a.isInfant = 1
                                THEN 'P51_FULL'

                            -- male assigned from TMB resource → P51 rate
                            WHEN a.sex = 'M'
                                THEN 'P51_FULL'

                            -- default: day lease to TMB
                            ELSE 'DAY_LEASE'
                        END

                    -- 1.3 Aging (0456) → no lease for assignments
                    WHEN a.resourceGroup = 'AGING' THEN 'NONE'

                    -- 1.4 OBESE (0833)
                    WHEN a.resourceGroup = 'OBESE' THEN
                        CASE
                            WHEN a.assignmentDays BETWEEN 1 AND 14
                                 AND a.hasConditionChange = 0
                                THEN 'OBESE_DAY'          -- ONR01
                            WHEN a.isTerminalAssignment = 1
                                THEN 'OBESE_ADULT_TERM'   -- ONR45
                            ELSE 'OBESE_ADULT'            -- ONR25
                        END

                    -- 1.5 SPF9 (0492-03)
                    WHEN a.resourceGroup = 'SPF9'
                        THEN 'SPF9_EXPANDED'

                    -- 1.6 AMR (1092-50) – no lease when assigned to AMR
                    WHEN a.resourceGroup = 'AMR'
                        THEN 'NONE'

                    -- 1.7 Colony / U42 / JMR / Other resource → P51 rules
                    ELSE 'P51_FULL'
                END

            -- 2) Research assignments
            ELSE
                CASE
                    -- 2.1 PI Purchased → no lease
                    WHEN a.hasPIPurchase = 1
                        THEN 'NONE'

                    -- 2.2 One day – 14 days
                    WHEN a.assignmentDays BETWEEN 1 AND 14 THEN
                        CASE
                            WHEN a.hasConditionChange = 0
                                THEN 'DAY_LEASE'
                            ELSE 'FULL_LEASE'
                        END

                    -- 2.3 > 14 days → full lease
                    WHEN a.assignmentDays > 14
                        THEN 'FULL_LEASE'

                    ELSE 'NONE'
                END
        END AS leaseType
    FROM with_dam_match a
),

-- =========================================================
-- 8) Map leaseType to itemCodes & credit aliases
-- ========================================================
lease_mapping AS (
    SELECT
        l.*,

        -- Item code mapping (example codes – replace with real ones)
        CASE l.leaseType
            WHEN 'DAY_LEASE'         THEN 'DAY01'   -- generic day lease
            WHEN 'FULL_LEASE'        THEN 'FULL01'
            WHEN 'P51_FULL'          THEN 'P51'
            WHEN 'OBESE_DAY'         THEN 'ONR01'
            WHEN 'OBESE_ADULT'       THEN 'ONR25'
            WHEN 'OBESE_ADULT_TERM'  THEN 'ONR45'
            WHEN 'SPF9_EXPANDED'     THEN 'SPF9X'
            WHEN 'TMB_LEASE'         THEN 'TMB01'
            ELSE NULL
        END AS leaseItemCode,

        -- Credit resource mapping (aliases to be tied to real chargeableItems / accounts)
        CASE
            WHEN l.leaseType = 'NONE' THEN NULL

            -- Aging never gets credit; credit colony
            WHEN l.resourceGroup = 'AGING' THEN 'COLONY_ALIAS'

            -- Obese always credits Obese resource
            WHEN l.resourceGroup = 'OBESE' THEN 'OBESE_ALIAS'

            -- SPF9 credits U42E funding
            WHEN l.resourceGroup = 'SPF9' THEN 'U42E_ALIAS'

            -- TMB credits TMB resource
            WHEN l.resourceGroup = 'TMB'  THEN 'TMB_ALIAS'

            -- AMR → credit colony
            WHEN l.resourceGroup = 'AMR'  THEN 'COLONY_ALIAS'

            -- Colony/U42/JMR map to their own aliases
            WHEN l.resourceGroup = 'COLONY' THEN 'COLONY_ALIAS'
            WHEN l.resourceGroup = 'U42'    THEN 'U42_ALIAS'
            WHEN l.resourceGroup = 'JMR'    THEN 'JMR_ALIAS'

            -- fallback: credit the originating resource
            ELSE 'ORIGIN_RESOURCE_ALIAS'
        END AS creditAlias
    FROM lease_type l
),

-- =========================================================
-- 9) Final output
-- ========================================================
final AS (
    SELECT
        f.Id,
        f.assignmentId,
        f.assignmentDate,
        f.assignmentEndDate,
        f.project,
        f.resourceCode,
        f.resourceGroup,
        f.isResearchAssignment,
        f.isInfant,
        f.assignmentDays,
        f.hasConditionChange,
        f.hasPIPurchase,
        f.isTerminalAssignment,
        f.leaseType,
        f.leaseItemCode,
        f.creditAlias,
        CASE
            WHEN f.leaseType = 'NONE'
                THEN 'No lease per business rules'
            ELSE ('Lease generated per leaseType=' + f.leaseType)
        END AS leaseNote
    FROM lease_mapping f
)

SELECT *
FROM final
ORDER BY assignmentDate, Id, assignmentId;
