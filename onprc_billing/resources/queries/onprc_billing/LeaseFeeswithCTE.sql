PARAMETERS (StartDate TIMESTAMP, EndDate TIMESTAMP)

WITH
-- ------------------------------------------------------------------
-- Shared lookups / container paths
-- ------------------------------------------------------------------
billing_charge_items AS (
    SELECT *
    FROM Site.{substitutePath moduleProperty('ONPRC_Billing','BillingContainer')}
         .onprc_billing.chargeableItems
),
public_charge_items AS (
    SELECT *
    FROM onprc_billing_public.chargeableItems
),
births AS (
    SELECT *
    FROM study.birth
),
resource_assignments AS (
    SELECT *
    FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}
         .study.assignment
),
flags_4034 AS (
    SELECT f.*
    FROM study.flags f
    WHERE f.flag.code = 4034
),
lease_defs AS (
    SELECT *
    FROM onprc_billing.leaseFeeDefinition
    WHERE active = true
),

-- ------------------------------------------------------------------
-- Base assignment sets (filter by QC + date ranges once)
-- ------------------------------------------------------------------
assign_finalized AS (
    SELECT a.*
    FROM study.assignment a
    WHERE a.qcstate.publicdata = true
      AND CAST(a.datefinalized AS DATE) >= CAST(STARTDATE AS DATE)
      AND CAST(a.datefinalized AS DATE) <= CAST(ENDDATE AS DATE)
),
assign_end_finalized AS (
    SELECT a.*
    FROM study.assignment a
    WHERE a.qcstate.publicdata = true
      AND a.enddatefinalized IS NOT NULL
      AND CAST(a.enddatefinalized AS DATE) >= CAST(STARTDATE AS DATE)
      AND CAST(a.enddatefinalized AS DATE) <= CAST(ENDDATE AS DATE)
),

-- ------------------------------------------------------------------
-- Standard lease fee rows
-- ------------------------------------------------------------------
standard_rows AS (
    SELECT
        a.id,
        a.date,
        a.project,
        a.date AS assignmentStart,
        a.enddate,
        a.projectedReleaseCondition,
        a.releaseCondition,
        a.assignCondition,
        a.releaseType,
        a5.id AS ESPFAnimal,
        a.ageAtTime.AgeAtTimeYearsRounded AS ageAtTime,
        'Lease Fees' AS category,

        -- chargeId selection
        CASE
            -- Determine if the animal is currently an Obese Animal / part of 0833 / etc.
            -- U42 ESPF dual assignment
            WHEN a5.id IS NOT NULL
                THEN '5348'

            -- remove setup fee from Day Leases
            WHEN (
                    a3.id IS NOT NULL
                    AND (TIMESTAMPDIFF('SQL_TSI_Day', a.date, a.projectedRelease) <= 14 AND a.enddate IS NULL)
                 )
                 AND a.assignCondition = a.projectedreleasecondition
                THEN (
                    SELECT c.rowid
                    FROM public_charge_items c
                    WHERE c.itemCode = 'ONR01'
                )

            -- short term obese lease (0833 / 0622 etc., >14 and <90 days)
            WHEN (
                    a3.id IS NOT NULL
                    AND (
                        TIMESTAMPDIFF('SQL_TSI_Day', a.date, a.projectedRelease) > 14
                        AND TIMESTAMPDIFF('SQL_TSI_Day', a.date, a.projectedRelease) < 90
                    )
                    AND a.assignCondition = a.projectedreleasecondition
                    AND a.enddate IS NULL
                 )
                THEN (
                    SELECT c.rowid
                    FROM billing_charge_items c
                    WHERE c.itemCode = 'ONR24'
                )

            -- obese long term terminal assignment
            WHEN (
                    a3.id IS NOT NULL
                    AND TIMESTAMPDIFF('SQL_TSI_Day', a.date, a.projectedRelease) > 90
                    AND a.enddate IS NULL
                    AND a.projectedReleaseCondition = 206
                 )
                THEN (
                    SELECT c.rowid
                    FROM billing_charge_items c
                    WHERE c.itemCode = 'ONR45'
                )

            -- obese long term (>90 days)
            WHEN (
                    a3.id IS NOT NULL
                    AND TIMESTAMPDIFF('SQL_TSI_Day', a.date, a.projectedRelease) > 90
                    AND a.enddate IS NULL
                 )
                THEN (
                    SELECT c.rowid
                    FROM billing_charge_items c
                    WHERE c.itemCode = 'ONR25'
                )

            -- Infant/Dam Day Lease
            WHEN (
                    a4.id IS NOT NULL
                    AND TIMESTAMPDIFF('SQL_TSI_Day', a.date, a.projectedRelease) <= 14
                    AND a.endDate IS NULL
                    AND a.ageAtTime.AgeAtTimeYearsRounded < 1
                    AND a.remark LIKE '%Diet%'
                 )
                THEN (
                    SELECT c.rowid
                    FROM billing_charge_items c
                    WHERE c.itemCode = 'ONR40'
                )

            WHEN (
                    a4.id IS NOT NULL
                    AND TIMESTAMPDIFF('SQL_TSI_Day', a.date, a.projectedRelease) <= 14
                    AND a.endDate IS NULL
                    AND a.ageAtTime.AgeAtTimeYearsRounded < 1
                    AND a.remark LIKE 'Control%'
                 )
                THEN (
                    SELECT c.rowid
                    FROM billing_charge_items c
                    WHERE c.itemCode = 'ONR41'
                )

            WHEN (
                    a4.id IS NOT NULL
                    AND TIMESTAMPDIFF('SQL_TSI_Day', a.date, a.projectedRelease) <= 14
                    AND a.endDate IS NULL
                    AND a.ageAtTime.AgeAtTimeYearsRounded < 1
                 )
                THEN (
                    SELECT c.rowid
                    FROM billing_charge_items c
                    WHERE c.itemCode = 'ONR44'
                )

            -- one-day/short assignments
            WHEN (
                    a.duration <= CAST(javaConstant('org.labkey.onprc_billing.ONPRC_BillingManager.DAY_LEASE_MAX_DURATION') AS INTEGER)
                    AND a.enddate IS NOT NULL
                    AND a.assignCondition = a.releaseCondition
                 )
                THEN (
                    SELECT ci.rowid
                    FROM public_charge_items ci
                    WHERE ci.active = TRUE
                      AND ci.name = javaConstant('org.labkey.onprc_billing.ONPRC_BillingManager.DAY_LEASE_NAME')
                )

            -- (duplicate WHEN from original kept intentionally)
            WHEN (
                    a.duration <= CAST(javaConstant('org.labkey.onprc_billing.ONPRC_BillingManager.DAY_LEASE_MAX_DURATION') AS INTEGER)
                    AND a.enddate IS NOT NULL
                    AND a.assignCondition = a.releaseCondition
                 )
                THEN (
                    SELECT ci.rowid
                    FROM public_charge_items ci
                    WHERE ci.active = TRUE
                      AND ci.name = javaConstant('org.labkey.onprc_billing.ONPRC_BillingManager.DAY_LEASE_NAME')
                )

            -- TMB lease
            WHEN a2.id IS NOT NULL
                THEN (
                    SELECT ci.rowid
                    FROM public_charge_items ci
                    WHERE (ci.startDate <= a.date AND ci.endDate >= a.date)
                      AND ci.name = javaConstant('org.labkey.onprc_billing.ONPRC_BillingManager.TMB_LEASE_NAME')
                )

            ELSE lf.chargeId
        END AS chargeId,

        -- quantity logic
        CASE
            WHEN a3.id IS NOT NULL
                 AND TIMESTAMPDIFF('SQL_TSI_Day', a.date, a.projectedRelease) > 14
                THEN 1
            WHEN a4.id IS NOT NULL
                 AND TIMESTAMPDIFF('SQL_TSI_Day', a.date, a.projectedRelease) > 14
                THEN 1
            WHEN a3.id IS NOT NULL
                 AND TIMESTAMPDIFF('SQL_TSI_Day', a.date, a.projectedRelease) <= 14
                THEN TIMESTAMPDIFF('SQL_TSI_Day', a.date, a.projectedRelease)
            WHEN a4.id IS NOT NULL
                 AND TIMESTAMPDIFF('SQL_TSI_Day', a.date, a.projectedRelease) <= 14
                THEN TIMESTAMPDIFF('SQL_TSI_Day', a.date, a.projectedRelease)
            WHEN a4.id IS NOT NULL
                 AND TIMESTAMPDIFF('SQL_TSI_Day', a.date, a.projectedRelease) > 14
                THEN TIMESTAMPDIFF('SQL_TSI_Day', a.date, a.projectedRelease)

            -- This looks for TMB infant and sets count to 0 based on mom being TMB
            WHEN (
                SELECT COUNT(*) AS c
                FROM births b
                     LEFT JOIN resource_assignments a1
                        ON b.id = a.id AND a.date = b.dateOnly
                     LEFT JOIN resource_assignments a2
                        ON b.dam = a2.id
                       AND a2.project = 559
                       AND (
                              (a2.date <= b.dateOnly AND a2.endDate >= b.dateOnly)
                              OR a2.enddate IS NULL
                           )
                WHERE b.id = a.id
                  AND a1.project.protocol != a2.project.protocol
            ) > 0
                THEN 0

            -- infants born to resource dams
            WHEN (
                SELECT COUNT(*) AS c
                FROM births b
                     LEFT JOIN resource_assignments a1
                        ON b.id = a.id
                       AND a.date = b.dateOnly
                       AND a.project.use_category IN ('Center Resource', 'U42', 'U24')
                     LEFT JOIN resource_assignments a2
                        ON b.dam = a2.id
                       AND a2.project.use_category IN ('Center Resource', 'U42', 'U24')
                       AND (
                              (a2.date <= b.dateOnly AND a2.endDate >= b.dateOnly)
                              OR a2.enddate IS NULL
                           )
                WHERE b.id = a.id
                  AND a1.project.protocol = a2.project.protocol
            ) > 0
                THEN 0

            WHEN (a.duration = 0 AND a.enddate IS NOT NULL AND a.assignCondition = a.releaseCondition)
                THEN 1

            WHEN (fl.id IS NOT NULL)
                THEN 0

            WHEN (
                    a.duration <= CAST(javaConstant('org.labkey.onprc_billing.ONPRC_BillingManager.DAY_LEASE_MAX_DURATION') AS INTEGER)
                    AND a.enddate IS NOT NULL
                    AND a.assignCondition = a.releaseCondition
                 )
                THEN a.duration

            ELSE 1
        END AS quantity,

        CAST(NULL AS INTEGER) AS leaseCharge1,
        CAST(NULL AS INTEGER) AS leaseCharge2,
        a.objectid AS sourceRecord,
        NULL AS chargeCategory,
        NULL AS isAdjustment,
        a.datefinalized,
        a.enddatefinalized
    FROM assign_finalized a

    -- find overlapping TMB at date of assignment
    LEFT JOIN study.assignment a2 ON (
        a.id = a2.id
        AND a.project != a2.project
        AND a2.dateOnly <= a.dateOnly
        AND a2.endDateCoalesced >= a.dateOnly
        AND a2.project.name = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.TMB_PROJECT')
    )

    -- Obese 0833 animals id 1609
    LEFT JOIN onprc_billing.assignment_ObeseResource a3 ON (
        a.id = a3.id
        AND a.project != a3.project
        AND a3.project = 1609
        AND a3.dateonly <= a.dateOnly
        AND a3.endDateCoalesced >= a.dateOnly
    )

    -- Obese 0622-01 animals id 1082
    LEFT JOIN onprc_billing.assignment_ObeseResource a4 ON (
        a.id = a4.id
        AND a.project != a4.project
        AND a4.project = 1082
        AND a4.dateonly <= a.dateOnly
        AND a4.endDateCoalesced >= a.dateOnly
    )

    -- ESPF animals being dual assigned
    LEFT JOIN assignment_U42ESPF a5 ON (
        a.id = a5.id
        AND a.project != a5.project
        AND a5.project = 1107
        AND a5.dateonly <= a.dateOnly
        AND a5.endDateCoalesced >= a.dateOnly
    )

    -- lease fee definition
    LEFT JOIN lease_defs lf ON (
        a3.id IS NULL
        AND a4.id IS NULL
        AND a5.id IS NULL
        AND lf.assignCondition = a.assignCondition
        AND lf.releaseCondition = a.projectedReleaseCondition
        AND (a.ageAtTime.AgeAtTimeYearsRounded >= lf.minAge OR lf.minAge IS NULL)
        AND (a.ageAtTime.AgeAtTimeYearsRounded < lf.maxAge OR lf.maxAge IS NULL)
    )

    -- research-owned animal exemption
    LEFT JOIN flags_4034 fl ON (
        a.id = fl.id
        AND a.date >= fl.date
        AND a.date <= COALESCE(fl.enddate, NOW())
    )
),

-- ------------------------------------------------------------------
-- Lease setup fee rows
-- ------------------------------------------------------------------
setup_rows AS (
    SELECT
        a.id,
        a.date,
        a.project,
        a.date AS assignmentStart,
        a.enddate,
        a.projectedReleaseCondition,
        a.releaseCondition,
        a.assignCondition,
        a.releaseType,
        a.ageAtTime.AgeAtTimeYearsRounded AS ageAtTime,
        ' ' AS ESPFAnimal,
        'Lease Setup Fees' AS category,
        (
            SELECT ci.rowid
            FROM public_charge_items ci
            WHERE ci.active = TRUE
              AND ci.name = javaConstant('org.labkey.onprc_billing.ONPRC_BillingManager.LEASE_SETUP_FEES')
        ) AS chargeId,
        1 AS quantity,
        CAST(NULL AS INTEGER) AS leaseCharge1,
        CAST(NULL AS INTEGER) AS leaseCharge2,
        a.objectid AS sourceRecord,
        NULL AS chargeCategory,
        NULL AS isAdjustment,
        a.datefinalized,
        a.enddatefinalized
    FROM assign_finalized a
    WHERE
        -- only charge setup fee for leases > 24H.
        -- note: duration assumes today as end, so exclude null enddates
        (
            a.duration > CAST(javaConstant('org.labkey.onprc_billing.ONPRC_BillingManager.DAY_LEASE_MAX_DURATION') AS INTEGER)
            OR (a.assignCondition != a.releaseCondition AND a.enddate IS NULL)
        )
        AND a.id.demographics.species NOT IN ('Rabbit', 'Guinea Pigs')
),

-- ------------------------------------------------------------------
-- Adjustment rows for released animals
-- ------------------------------------------------------------------
adjustment_rows AS (
    SELECT
        a.id,
        CASE
            WHEN a.enddate < a.dateFinalized THEN a.dateFinalized
            ELSE a.enddate
        END AS date,
        a.project,
        a.date AS assignmentStart,
        a.enddate,
        a.projectedReleaseCondition,
        a.releaseCondition,
        a.assignCondition,
        a.releaseType,
        a.ageAtTime.AgeAtTimeYearsRounded AS ageAtTime,
        a5.id AS ESPFAnimal,
        'Lease Fees' AS category,
        (
            SELECT MAX(ci.rowid) AS rowid
            FROM public_charge_items ci
            WHERE ci.name = javaConstant('org.labkey.onprc_billing.ONPRC_BillingManager.LEASE_FEE_ADJUSTMENT')
              AND ci.active = TRUE
        ) AS chargeId,
        CASE
            WHEN (fl.id IS NOT NULL) THEN 0
            ELSE 1
        END AS quantity,
        lf2.chargeId AS leaseCharge1,
        lf.chargeId AS leaseCharge2,
        a.objectid AS sourceRecord,
        'Adjustment - Automatic' AS chargeCategory,
        'Y' AS isAdjustment,
        a.datefinalized,
        a.enddatefinalized
    FROM assign_end_finalized a

    LEFT JOIN onprc_billing.leaseFeeDefinition lf ON (
        lf.assignCondition = a.assignCondition
        AND lf.releaseCondition = a.releaseCondition
        AND (a.ageAtTime.AgeAtTimeYearsRounded >= lf.minAge OR lf.minAge IS NULL)
        AND (a.ageAtTime.AgeAtTimeYearsRounded < lf.maxAge OR lf.maxAge IS NULL)
    )

    LEFT JOIN onprc_billing.leaseFeeDefinition lf2 ON (
        lf2.assignCondition = a.assignCondition
        AND lf2.releaseCondition = a.projectedReleaseCondition
        AND (a.ageAtTime.AgeAtTimeYearsRounded >= lf2.minAge OR lf2.minAge IS NULL)
        AND (a.ageAtTime.AgeAtTimeYearsRounded < lf2.maxAge OR lf2.maxAge IS NULL)
        AND (a.date >= lf2.startDate AND a.date <= lf2.endDate)
    )

    -- find overlapping TMB at date of assignment
    LEFT JOIN study.assignment a2 ON (
        a.id = a2.id
        AND a.project != a2.project
        AND a2.dateOnly <= a.dateOnly
        AND a2.endDateCoalesced >= a.dateOnly
        AND a2.project.name = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.TMB_PROJECT')
    )

    LEFT JOIN assignment_U42ESPF a5 ON (
        a.id = a5.id
        AND a.project != a5.project
        AND a5.project = 1107
        AND a5.dateonly <= a.dateOnly
        AND a5.endDateCoalesced >= a.dateOnly
    )

    -- research-owned animal exemption
    LEFT JOIN flags_4034 fl ON (
        a.id = fl.id
        AND a.date >= fl.date
        AND a.date <= COALESCE(fl.enddate, NOW())
    )

    WHERE
        a.releaseCondition != a.projectedReleaseCondition
        AND (a.id != a5.id OR a5.id IS NULL)
        AND lf.active = TRUE
        AND a2.id IS NULL
        AND a.participantID NOT LIKE '[a-z]%'
)

-- ------------------------------------------------------------------
-- Final unified result
-- ------------------------------------------------------------------
SELECT * FROM standard_rows
UNION ALL
SELECT * FROM setup_rows
UNION ALL
SELECT * FROM adjustment_rows;
