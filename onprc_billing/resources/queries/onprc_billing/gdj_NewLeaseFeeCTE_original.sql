PARAMETERS (StartDate TIMESTAMP, EndDate TIMESTAMP)
-- ========================================================
-- This is the QUery using CTES that was AI Generated for revised lease fees
-- Date:  2025-11-22
-- Step 1 Assignments has bene modified to use LabkeySQL structure.
-- THis was moved to the onprc_billing query section
-- Working thru each CTE for code updates -  Works as Designed in Dev
-- =========================================================
WITH
-- =========================================================
-- 1) Base assignments in date range
--This was modified to use LabkeySQL structure.
-- 2025-11-24 Validation of this CTE
-- =========================================================
assignments AS (
    SELECT
        a.Id,
        -- create an identifer as assignment ID
        a.lsid as assignmentId,
        a.date            AS assignmentDate,
        a.enddate         AS assignmentEndDate,
        a.project,
        --Create a sub query for resource ID
        (Select r.project.displayName from study.resourceAssigned r where r.id = a.id) as resourceCode,
        a.assignCondition,
        a.releaseCondition,
        a.projectedRelease,
        --Create a looklup for is a research project
        Case when a.id in (Select ra.id from study.researchAssigned ra where ra.id = a.id) then 1
           Else 0
           End as isResearchAssignment,
       -- a.isResearchAssignment,   -- 1 = research, 0 = resource (or derive later)
        (Select b.dam from study.birth b where b.id = a.id) as damId,                  -- dam of infant, if applicable
        a.id.dataset.Demographics.gender as sex,
        -- Using the release code assign a value for is terminal
        Case when a.projectedReleaseCondition in (206,207) then 1
        Else 0
        End as isTerminalAssignment,   -- 1 = terminal, 0 = non-terminal
        a.container
    FROM study.assignment a
    WHERE a.date >= StartDate
      AND a.date <  EndDate
),
--Select * from assignment,

-- =========================================================
-- 2) Animal age / infant vs adult
--    (You may already have an ageAtTime dataset; this is illustrative)
-- change this to age in years
-- 2025-11-24 Starting Validation Review
-- =========================================================
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
        aa.sex,
        aa.isTerminalAssignment,
        aa.isResearchAssignment,
        aa.container,
        d.birth,
        -- change this to accepted Labkey Code
        TIMESTAMPDIFF('SQL_TSI_day', d.birth, aa.assignmentDate) AS ageDays,
        CASE
            WHEN TIMESTAMPDIFF('SQL_TSI_YEAR', d.birth, aa.assignmentDate) <= 1 THEN 1   -- infant threshold example
            ELSE 0
        END AS isInfant
    FROM assignments aa
    LEFT JOIN study.demographics d
        ON d.Id = aa.Id
)
--Select * from age_at_assignment

,

-- =========================================================
-- 3) PI purchase flag (for research assignments)
-- =========================================================
pi_purchase AS (
    SELECT DISTINCT
        f.Id,
        f.value,
        1 AS hasPIPurchase
    FROM study.flags f
   WHERE f.flag.value = 'PI Purchased NHP'
     --AND f.isActive = true
),

assign_with_pi AS (
    SELECT
        a.*,
        p.value,
        COALESCE(p.hasPIPurchase, 0) AS hasPIPurchase
    FROM age_at_assignment a
    LEFT JOIN pi_purchase p
        ON a.Id = p.Id
)
--select * from pi_purchase
           ,

-- =========================================================
-- 4) Assignment length & condition change
           --This is returening total days assigned to the project
-- =========================================================
assignment_length AS (
    SELECT
        a.*,
    TIMESTAMPDIFF('SQL_TSI_day', a.assignmentDate, COALESCE(a.projectedRelease, a.assignmentenddate)) AS assignmentDays,
        --DATEDIFF('day', a.assignmentDate, COALESCE(a.proposedReleaseDate, a.assignmentEndDate)) AS assignmentDays,
        CASE
            WHEN a.assignCondition = a.releaseCondition
                OR a.releaseCondition IS NULL
                THEN 0
            ELSE 1
        END AS hasConditionChange
    FROM assign_with_pi a
)
-- select * from assignment_length

           ,

-- =========================================================
-- 5) Resource type classification
-- =========================================================
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
)
 -- select * from resource_type

           ,

-- =========================================================
-- 6) Dam/resource match (for infant/resource rules)
--    You may need a proper housing/resource history join here.
-- =========================================================
dam_resource AS (
    SELECT
        r.Id,
        r.assignmentId,
        r.resourceCode AS damResourceCode
    FROM resource_type r
    WHERE r.damId IS NOT NULL
    -- join to housing/resource assignments if needed
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
        ON dr.Id = a.damId
       AND dr.assignmentId = a.assignmentId  -- or appropriate key
)
--   Select * from with_dam_match

,
-- =========================================================
-- 7) Determine lease type (core rule engine)
-- =========================================================
lease_type AS (
    SELECT
        a.*,

        -- Main lease type decision
        CASE
            -- ------------------------------
            -- 1) Resource assignments
            -- ------------------------------
            WHEN a.isResearchAssignment = 0 THEN
                CASE
                    -- 1.1 Infant, dam in same resource → no lease
                    WHEN a.isInfant = 1
                         AND a.infantSameDamResource = 1
                        THEN 'NONE'

                    -- 1.2 TMB (0300)
                    WHEN a.resourceGroup = 'TMB' THEN
                        CASE
                            -- TMB dam always charged a TMB lease
                            WHEN a.isInfant = 0
                                AND a.sex = 'F' -- example for dam logic
                                THEN 'TMB_LEASE'

                            -- infant from assigned TMB dam → no lease
                            WHEN a.isInfant = 1
                                 AND a.infantSameDamResource = 1
                                THEN 'NONE'

                            -- infant from unassigned TMB dam → P51 lease, credit TMB
                            WHEN a.isInfant = 1
                                THEN 'P51_FULL'

                            -- male assigned from TMB resource → P51 rate
                            WHEN a.sex = 'M'
                                THEN 'P51_FULL'

                            -- day lease to TMB
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

            -- ------------------------------
            -- 2) Research assignments
            -- ------------------------------
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
)
  --select * from lease_type
          ,
-- ++++++++ 2025-11-24 All CTEs above return results as expected
-- =========================================================
-- 8) Map leaseType to itemCodes & credit aliases
-- =========================================================
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

        -- Credit resource mapping
        CASE
            WHEN l.leaseType = 'NONE' THEN NULL

            -- Aging never gets credit; credit colony
            WHEN l.resourceGroup = 'AGING' THEN 'COLONY_ALIAS'

            -- Obese always credits Obese resource
            WHEN l.resourceGroup = 'OBESE' THEN 'OBESE_ALIAS'

            -- SPF9 credits U42e funding
            WHEN l.resourceGroup = 'SPF9' THEN 'U42E_ALIAS'

            -- TMB credits TMB resource
            WHEN l.resourceGroup = 'TMB'  THEN 'TMB_ALIAS'

            -- AMR → credit colony or original resource
            WHEN l.resourceGroup = 'AMR'  THEN 'COLONY_ALIAS'

            -- Colony/U42/JMR map to their own aliases
            WHEN l.resourceGroup = 'COLONY' THEN 'COLONY_ALIAS'
            WHEN l.resourceGroup = 'U42'    THEN 'U42_ALIAS'
            WHEN l.resourceGroup = 'JMR'    THEN 'JMR_ALIAS'

            -- fallback: credit the originating resource
            ELSE 'ORIGIN_RESOURCE_ALIAS'
        END AS creditAlias
    FROM lease_type l
)
--Select * from lease_mapping
,
-- =========================================================
-- 9) Final output
-- =========================================================
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
            ELSE ('Lease generated per leaseType=' || f.leaseType)
        END AS leaseNote
    FROM lease_mapping f
)

SELECT *
FROM final
ORDER BY assignmentDate, Id, assignmentId;
