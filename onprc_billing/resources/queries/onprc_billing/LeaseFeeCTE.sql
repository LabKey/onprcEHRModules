PARAMETERS (StartDate TIMESTAMP, EndDate TIMESTAMP)

-- ========================================================
-- Lease Fee Logic – Production Version (Revised)
--2025-12-15 jonesga Latest update changes in lease type
--test as Deploy Looks to have issues
--Cop0mpared to Staging lease fees and provided correct number of rows
-- ========================================================

WITH

-- ========================================================
-- 1) Base Assignments
-- ========================================================
assignments AS (
    SELECT
        a.Id,
        a.lsid AS assignmentId,
        a.date AS assignmentDate,
        a.enddate AS assignmentEndDate,
        a.project,

        -- Most recent resource assignment (LabKey-safe)
        (
            SELECT r.project.displayName
            FROM study.resourceAssigned r
            WHERE r.id = a.id
              AND (r.project.enddate IS NULL OR r.project.enddate >= a.date)
              AND r.project.startdate = (
                    SELECT MAX(r2.project.startdate)
                    FROM study.resourceAssigned r2
                    WHERE r2.id = a.id
              )
        ) AS resourceCode,

        a.assignCondition,
        a.releaseCondition,
        a.projectedRelease,
        a.projectedReleaseCondition,

        CASE WHEN EXISTS (
            SELECT 1 FROM study.researchAssigned ra WHERE ra.id = a.id
        ) THEN 1 ELSE 0 END AS isResearchAssignment,

        (
            SELECT b.dam
            FROM study.birth b
            WHERE b.id = a.id
              AND b.date = (
                    SELECT MAX(b2.date)
                    FROM study.birth b2
                    WHERE b2.id = a.id
              )
        ) AS damId,

        a.container
    FROM study.assignment a
    WHERE a.datefinalized >= StartDate
      AND (a.datefinalized <= EndDate OR a.enddate IS NULL)
),
-- ========================================================
-- 2) Age, infant status, demographics
-- ========================================================
age_at_assignment AS (
    SELECT
        aa.*,
        d.birth,
        d.gender AS sex,

        TIMESTAMPDIFF('SQL_TSI_YEAR', d.birth, aa.assignmentDate) AS ageYears,
        TIMESTAMPDIFF('SQL_TSI_DAY',  d.birth, aa.assignmentDate) AS ageDays,

        CASE WHEN TIMESTAMPDIFF('SQL_TSI_YEAR', d.birth, aa.assignmentDate) < 1
             THEN 1 ELSE 0 END AS isInfant,

        CASE WHEN aa.projectedReleaseCondition IN (206,207)
             THEN 1 ELSE 0 END AS isTerminalAssignment
    FROM assignments aa
    LEFT JOIN study.demographics d ON d.Id = aa.Id
),

-- ========================================================
-- 3) PI Purchase Flags
-- ========================================================
pi_purchase AS (
    SELECT
        f.Id,
        MAX(f.date) AS lastFlag,
        1 AS hasPIPurchase
    FROM study.flags f
    WHERE f.flag.value = 'PI Purchased NHP'
    GROUP BY f.Id
),

assign_with_pi AS (
    SELECT
        a.*,
        COALESCE(p.hasPIPurchase,0) AS hasPIPurchase
    FROM age_at_assignment a
    LEFT JOIN pi_purchase p ON p.Id = a.Id
),



-- ========================================================
assignment_length AS (
    SELECT
        a.*,

        -- Date-only diff to prevent false 1-day assignments
        TIMESTAMPDIFF(
            'SQL_TSI_DAY',
            CAST(a.assignmentDate AS DATE),
            CAST(COALESCE(a.projectedRelease, a.assignmentEndDate) AS DATE)
        ) AS assignmentDays,

        CASE
            WHEN a.assignCondition = a.releaseCondition
                 OR a.releaseCondition IS NULL
            THEN 0 ELSE 1 END AS hasConditionChange
    FROM assign_with_pi a
),

-- ========================================================
-- 5) Resource Type Mapping
-- ========================================================
resource_type AS (
    SELECT
        a.*,
        CASE
            WHEN a.resourceCode = '0300'    THEN 'TMB'
            WHEN a.resourceCode = '0456'    THEN 'AGING'
            WHEN a.resourceCode = '0833'    THEN 'OBESE'
            WHEN a.resourceCode = '0492-03' THEN 'SPF9'
            WHEN a.resourceCode = '1092-50' THEN 'AMR'
            WHEN a.resourceCode = '0492'    THEN 'COLONY'
            WHEN a.resourceCode = '0492-02' THEN 'U42'
            WHEN a.resourceCode = '0492-45' THEN 'JMR'
            ELSE 'OTHER'
        END AS resourceGroup
    FROM assignment_length a
),

-- ========================================================
-- 6) Infant / Dam / Resource Matching
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
            THEN 1 ELSE 0 END AS infantSameDamResource
    FROM resource_type a
    LEFT JOIN dam_resource dr ON dr.damId = a.damId
),

-- ========================================================
-- 7) Lease Type Determination
-- ========================================================
lease_type AS (
    SELECT
        a.*,
        CASE
            WHEN a.isResearchAssignment = 0 THEN
                CASE
                    WHEN a.isInfant = 1 AND a.infantSameDamResource = 1
                        THEN 'NONE'

                    WHEN a.resourceGroup = 'TMB'
                        THEN 'TMB_LEASE'

                    WHEN a.resourceGroup = 'AGING'
                        THEN 'NONE'

                    WHEN a.resourceGroup = 'OBESE' THEN
                        CASE
                            WHEN a.assignmentDays BETWEEN 0 AND 14
                                 AND a.hasConditionChange = 0
                                THEN 'OBESE_DAY'
                            WHEN a.isTerminalAssignment = 1
                                THEN 'OBESE_ADULT_TERM'
                            ELSE 'OBESE_ADULT'
                        END

                    WHEN a.resourceGroup = 'SPF9'
                        THEN 'SPF9_EXPANDED'

                    WHEN a.resourceGroup = 'AMR'
                        THEN 'NONE'

                  --  ELSE 'FULL_LEASE'
           /*     END
            ELSE
                CASE*/
                    WHEN a.hasPIPurchase = 1 THEN 'NONE'
                    WHEN a.assignmentDays BETWEEN 0 AND 14 THEN
                        CASE WHEN a.hasConditionChange = 0 THEN 'DAY_LEASE'
                             ELSE 'FULL_LEASE' END
                    WHEN a.assignmentDays > 14 THEN 'FULL_LEASE'
                    ELSE 'NONE'
                END
        END AS leaseType
    FROM with_dam_match a
)
Select * from lease_type
/*-- ========================================================
-- 8) Full Lease Matrix (LabKey-safe: aliases in first SELECT)
-- ========================================================
full_lease_matrix AS (
    SELECT
        'LT1'  AS matrixKey,
        '<1'   AS ageBucket,
        '201'  AS assignCond,
        '201'  AS releaseCond,
        '1533' AS chargeRowId
    UNION ALL SELECT 'LT2',  '<1',  '201', '202', '1534'
    UNION ALL SELECT 'LT3',  '<1',  '201', '204', '1535'
    UNION ALL SELECT 'LT4',  '<1',  '201', '206', '1537'
    UNION ALL SELECT 'LT5',  '<1',  '202', '202', '1538'
    UNION ALL SELECT 'LT6',  '<1',  '202', '204', '1539'
    UNION ALL SELECT 'LT7',  '<1',  '202', '206', '1541'
    UNION ALL SELECT 'LT8',  '<1',  '204', '204', '1546'
    UNION ALL SELECT 'LT9',  '<1',  '204', '206', '1548'
    UNION ALL SELECT 'LT10', '<1',  '207', '206', '5250'
    UNION ALL SELECT 'LT11', '<1',  '207', '207', '1551'

    UNION ALL SELECT 'LT20','1-4','201','201','1495'
    UNION ALL SELECT 'LT21','1-4','201','202','1496'
    UNION ALL SELECT 'LT22','1-4','201','204','1497'
    UNION ALL SELECT 'LT23','1-4','201','206','1499'
    UNION ALL SELECT 'LT24','1-4','202','202','1500'
    UNION ALL SELECT 'LT25','1-4','202','204','1501'
    UNION ALL SELECT 'LT26','1-4','202','206','1503'
    UNION ALL SELECT 'LT27','1-4','204','204','1508'
    UNION ALL SELECT 'LT28','1-4','204','206','1510'
    UNION ALL SELECT 'LT29','1-4','207','206','5253'
    UNION ALL SELECT 'LT30','1-4','207','207','1513'

    UNION ALL SELECT 'LT40','4+','201','201','5315'
    UNION ALL SELECT 'LT41','4+','201','202','5316'
    UNION ALL SELECT 'LT42','4+','201','204','5317'
    UNION ALL SELECT 'LT43','4+','201','206','5318'
    UNION ALL SELECT 'LT44','4+','202','202','5319'
    UNION ALL SELECT 'LT45','4+','202','204','5320'
    UNION ALL SELECT 'LT46','4+','202','206','5321'
    UNION ALL SELECT 'LT47','4+','204','204','5322'
    UNION ALL SELECT 'LT48','4+','204','206','5323'
    UNION ALL SELECT 'LT49','4+','207','206','5324'
    UNION ALL SELECT 'LT50','4+','207','207','5325'
),

-- ========================================================
-- 9) Match Full Lease to Matrix
-- ========================================================
full_lease_match AS (
    SELECT
        lt.assignmentId,
        lt.Id,
        lt.ageYears,
        lt.assignCondition,
        lt.projectedReleaseCondition,
        m.matrixKey,
        m.ageBucket,
        m.assignCond,
        m.releaseCond,
        m.chargeRowId
    FROM lease_type lt
    LEFT JOIN full_lease_matrix m
      ON (
            (m.ageBucket = '<1'  AND lt.ageYears < 1) OR
            (m.ageBucket = '1-4' AND lt.ageYears >= 1 AND lt.ageYears < 4) OR
            (m.ageBucket = '4+'  AND lt.ageYears >= 4)
         )
     AND m.assignCond = CAST(lt.assignCondition AS VARCHAR(5))
     AND m.releaseCond = CAST(lt.projectedReleaseCondition AS VARCHAR(5))
    WHERE lt.leaseType = 'FULL_LEASE'
),

-- ========================================================
-- 10) Lease Mapping → Charge IDs
-- ========================================================
lease_mapping AS (
    SELECT
        lt.*,

        CASE
            WHEN lt.leaseType = 'FULL_LEASE'
                THEN fm.chargeRowId
            WHEN lt.leaseType = 'DAY_LEASE'
                THEN '90'
            WHEN lt.leaseType = 'OBESE_DAY'
                THEN '5367'
            WHEN lt.leaseType = 'OBESE_ADULT'
                THEN '5368'
            WHEN lt.leaseType = 'OBESE_ADULT_TERM'
                THEN '5369'
            WHEN lt.leaseType = 'TMB_LEASE'
                THEN '1552'
            WHEN lt.leaseType = 'SPF9_EXPANDED'
                THEN '5348'
            ELSE NULL
        END AS chargeID,

        CASE
            WHEN lt.leaseType = 'NONE' THEN NULL
            WHEN lt.resourceGroup = 'AGING'  THEN 'COLONY_ALIAS'
            WHEN lt.resourceGroup = 'OBESE'  THEN 'OBESE_ALIAS'
            WHEN lt.resourceGroup = 'SPF9'   THEN 'U42E_ALIAS'
            WHEN lt.resourceGroup = 'TMB'    THEN 'TMB_ALIAS'
            WHEN lt.resourceGroup = 'AMR'    THEN 'COLONY_ALIAS'
            WHEN lt.resourceGroup = 'COLONY' THEN 'COLONY_ALIAS'
            WHEN lt.resourceGroup = 'U42'    THEN 'U42_ALIAS'
            WHEN lt.resourceGroup = 'JMR'    THEN 'JMR_ALIAS'
            ELSE 'ORIGIN_RESOURCE_ALIAS'
        END AS creditAlias

    FROM lease_type lt
    LEFT JOIN full_lease_match fm ON fm.assignmentId = lt.assignmentId
),

-- ========================================================
-- 11) Final Output
-- ========================================================
final AS (
    SELECT
        f.*,
        CASE
            WHEN f.leaseType = 'NONE'
                THEN 'No lease per business rules'
            ELSE CONCAT('Lease generated per leaseType=', f.leaseType)
        END AS leaseNote
    FROM lease_mapping f
)

SELECT *
FROM final
ORDER BY assignmentDate, Id, assignmentId;
