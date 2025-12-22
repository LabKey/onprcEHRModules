PARAMETERS (StartDate TIMESTAMP, EndDate TIMESTAMP)

WITH
-- =====================================================================================
-- 1) Base Lease Fees
-- =====================================================================================
base_lease AS (
    SELECT
        p.id,
        p.date,
        p.enddate,
        p.assignmentStart,
        p.project,
        p.project.displayName AS projectDisplayName,
        p.projectedReleaseCondition,
        p.releaseCondition,
        p.assignCondition,
        p.releaseType,
        p.ageAtTime,
        p.category,
        p.chargeId,
        p.leaseCharge1,
        p.leaseCharge2,
        p.sourceRecord,
        p.chargeCategory,
        p.quantity,
        p.isAdjustment,
        p.datefinalized,
        p.enddatefinalized
    FROM onprc_billing.leaseFees p
    WHERE CAST(p.date AS DATE) BETWEEN CAST(StartDate AS DATE) AND CAST(EndDate AS DATE)
      AND p.category = 'Lease Fees'
),

-- =====================================================================================
-- 2) Alias / Account Context
-- =====================================================================================
alias_context AS (
    SELECT
        bl.*,
        a.alias                               AS account,
        a.category                            AS aliasCategory,
        a.faRate                              AS faRate,
        a.aliasType.aliasType                 AS aliasType,
        a.aliasType.removeSubsidy             AS removeSubsidy,
        a.aliasType.canRaiseFA                AS canRaiseFA,
        a.fiscalAuthority.faid                AS faid,
        a.aliasEnabled                        AS aliasEnabled,
        a.budgetStartDate                     AS budgetStartDate,
        a.budgetEndDate                       AS budgetEndDate,
        a.projectStatus                       AS projectStatus,
        COALESCE(a.investigatorId, bl.project.investigatorId) AS investigatorId
    FROM base_lease bl
    LEFT JOIN onprc_billing_public.projectAccountHistory pah
           ON pah.project = bl.project
          AND pah.startDate <= CAST(bl.date AS DATE)
          AND pah.endDate   >= CAST(bl.date AS DATE)
    LEFT JOIN onprc_billing_public.aliases a
           ON pah.account = a.alias
),

-- =====================================================================================
-- 3) Rates / Exemptions / Multipliers / Indirect Rate
-- =====================================================================================
rate_context AS (
    SELECT
        ac.*,

        cr.unitCost      AS nihRate1,
        cr.subsidy       AS subsidy1,
        e.unitCost       AS exemptRate1,
        e.rowid          AS exemptionId1,

        cr2.unitCost     AS nihRate2,
        cr2.subsidy      AS subsidy2,
        e2.unitCost      AS exemptRate2,
        e2.rowid         AS exemptionId2,

        cr3.unitCost     AS nihRate3,
        cr3.subsidy      AS subsidy3,
        e3.unitCost      AS exemptRate3,
        e3.rowid         AS exemptionId3,

        pm.multiplier    AS multiplier,
        ir.indirectRate  AS indirectRate
    FROM alias_context ac

    LEFT JOIN onprc_billing_public.chargeRates cr
           ON ac.assignmentStart >= cr.startDate
          AND (ac.assignmentStart <= cr.enddateCoalesced OR cr.enddate IS NULL)
          AND ac.chargeId = cr.chargeId

    LEFT JOIN onprc_billing_public.chargeRateExemptions e
           ON ac.assignmentStart >= e.startDate
          AND (ac.assignmentStart <= e.enddateCoalesced OR e.enddate IS NULL)
          AND ac.chargeId = e.chargeId
          AND ac.project = e.project

    LEFT JOIN onprc_billing_public.chargeRates cr2
           ON ac.assignmentStart >= cr2.startDate
          AND (ac.assignmentStart <= cr2.enddateCoalesced OR cr2.enddate IS NULL)
          AND ac.leaseCharge1 = cr2.chargeId

    LEFT JOIN onprc_billing_public.chargeRateExemptions e2
           ON ac.assignmentStart >= e2.startDate
          AND (ac.assignmentStart <= e2.enddateCoalesced OR e2.enddate IS NULL)
          AND ac.leaseCharge1 = e2.chargeId
          AND ac.project = e2.project

    LEFT JOIN onprc_billing_public.chargeRates cr3
           ON ac.assignmentStart >= cr3.startDate
          AND (ac.assignmentStart <= cr3.enddateCoalesced OR cr3.enddate IS NULL)
          AND ac.leaseCharge2 = cr3.chargeId

    LEFT JOIN onprc_billing_public.chargeRateExemptions e3
           ON ac.assignmentStart >= e3.startDate
          AND (ac.assignmentStart <= e3.enddateCoalesced OR e3.enddate IS NULL)
          AND ac.leaseCharge2 = e3.chargeId
          AND ac.project = e3.project

    LEFT JOIN onprc_billing_public.projectMultipliers pm
           ON ac.date >= pm.startDate
          AND (ac.date <= pm.enddateCoalesced OR pm.enddate IS NULL)
          AND ac.account = pm.account

    LEFT JOIN onprc_billing.ogaSynchIR ir
           ON ir.alias = ac.account
),

-- =====================================================================================
-- 4) Unit Cost Calculation
-- =====================================================================================
calculated_costs AS (
    SELECT
        rc.*,
        CAST(
            CASE
                WHEN exemptRate1 IS NOT NULL THEN exemptRate1

                WHEN multiplier IS NOT NULL AND nihRate1 IS NOT NULL
                    THEN (CAST(nihRate1 AS DOUBLE) * CAST(multiplier AS DOUBLE))

                WHEN nihRate1 IS NULL THEN NULL

                WHEN aliasCategory IS NOT NULL AND aliasCategory <> 'OGA'
                    THEN nihRate1

                WHEN aliasType IS NULL THEN NULL

                WHEN removeSubsidy = TRUE
                     AND canRaiseFA = TRUE
                     AND chargeId.canRaiseFA = TRUE
                    THEN (
                        (CAST(nihRate1 AS DOUBLE) / NULLIF((1 - COALESCE(subsidy1, 0)), 0))
                        *
                        (
                            1 +
                            CASE
                                WHEN faRate IS NOT NULL
                                     AND indirectRate IS NOT NULL
                                     AND faRate < CAST(indirectRate AS DOUBLE)
                                    THEN (CAST(indirectRate AS DOUBLE) / (1 + faRate))
                                ELSE 0
                            END
                        )
                    )

                WHEN removeSubsidy = TRUE AND canRaiseFA = FALSE
                    THEN (CAST(nihRate1 AS DOUBLE) / NULLIF((1 - COALESCE(subsidy1, 0)), 0))

                WHEN removeSubsidy = FALSE
                     AND canRaiseFA = TRUE
                     AND chargeId.canRaiseFA = TRUE
                    THEN (
                        CAST(nihRate1 AS DOUBLE)
                        *
                        (
                            1 +
                            CASE
                                WHEN faRate IS NOT NULL
                                     AND indirectRate IS NOT NULL
                                     AND faRate < CAST(indirectRate AS DOUBLE)
                                    THEN ((CAST(indirectRate AS DOUBLE) - faRate) / (1 + faRate))
                                ELSE 0
                            END
                        )
                    )

                ELSE nihRate1
            END
        AS DOUBLE) AS unitCost
    FROM rate_context rc
),

-- =====================================================================================
-- 5) Final Lease Charges
-- =====================================================================================
lease_final AS (
    SELECT
        id,
        date,
        enddate,
        datefinalized              AS dateFinalized,

        project,
        account,

        projectedReleaseCondition,
        releaseCondition,
        assignCondition,
        releaseType,
        ageAtTime,

        category,
        chargeId,
        chargeId.departmentCode    AS serviceCenter,
        chargeId.name              AS item,

        leaseCharge1,
        leaseCharge2,
        leaseCharge1.name          AS InitialLeaseType,
        leaseCharge2.name          AS FinalLeaseType,

        sourceRecord,
        chargeCategory,

        unitCost,
        nihRate1                   AS nihRate,
        quantity,

        CASE
            WHEN isAdjustment IS NOT NULL
                THEN ROUND(CAST(unitCost AS DOUBLE), 2)
            ELSE
                ROUND(
                    CAST(unitCost AS DOUBLE) * COALESCE(CAST(quantity AS DOUBLE), 1),
                    2
                )
        END AS totalCost,

        investigatorId,

        CAST(NULL AS VARCHAR(200))   AS creditAccount,
        CAST(NULL AS VARCHAR(200))   AS creditAccountType,
        CAST(NULL AS VARCHAR(4000))  AS comment,
        CAST(NULL AS INTEGER)        AS creditAccountId,

        CAST(NULL AS INTEGER)        AS rateId,
        exemptionId1                 AS exemptionId,

        CAST(NULL AS VARCHAR(1))     AS isMiscCharge,
        isAdjustment
    FROM calculated_costs
    WHERE id.demographics.species NOT IN ('Rabbit', 'Guinea Pig')
),

-- =====================================================================================
-- 6) Misc Charges (Lease Fees category)
-- =====================================================================================
misc_charges AS (
    SELECT
        mc.id,
        mc.billingDate             AS date,
        CAST(NULL AS TIMESTAMP)    AS enddate,
        CAST(NULL AS TIMESTAMP)    AS dateFinalized,

        mc.project,
        mc.account,

        CAST(NULL AS VARCHAR(200)) AS projectedReleaseCondition,
        CAST(NULL AS VARCHAR(200)) AS releaseCondition,
        CAST(NULL AS VARCHAR(200)) AS assignCondition,
        CAST(NULL AS VARCHAR(200)) AS releaseType,
        CAST(NULL AS DOUBLE)       AS ageAtTime,

        mc.category,
        mc.chargeId,
        mc.serviceCenter,
        mc.item,

        CAST(NULL AS INTEGER)      AS leaseCharge1,
        CAST(NULL AS INTEGER)      AS leaseCharge2,
        CAST(NULL AS VARCHAR(200)) AS InitialLeaseType,
        CAST(NULL AS VARCHAR(200)) AS FinalLeaseType,

        mc.sourceRecord,
        mc.chargeCategory,

        mc.unitCost,
        mc.nihRate                 AS nihRate,
        mc.quantity,

        ROUND(
            CAST(mc.unitCost AS DOUBLE) * COALESCE(CAST(mc.quantity AS DOUBLE), 1),
            2
        ) AS totalCost,

        mc.investigatorId,

        mc.creditAccount           AS creditAccount,
        mc.creditAccountType       AS creditAccountType,
        mc.comment                 AS comment,
        mc.creditAccountId         AS creditAccountId,

        mc.rateId                  AS rateId,
        mc.exemptionId             AS exemptionId,

        'Y'                        AS isMiscCharge,
        mc.isAdjustment            AS isAdjustment
    FROM onprc_billing.miscChargesFeeRateData mc
    WHERE CAST(mc.billingDate AS DATE) BETWEEN CAST(StartDate AS DATE) AND CAST(EndDate AS DATE)
      AND mc.category = 'Lease Fees'
)

-- =====================================================================================
-- FINAL OUTPUT (explicit column list; no SELECT *)
-- =====================================================================================
SELECT
    id,
    date,
    enddate,
    dateFinalized,
    project,
    account,
    projectedReleaseCondition,
    releaseCondition,
    assignCondition,
    releaseType,
    ageAtTime,
    category,
    chargeId,
    serviceCenter,
    item,
    leaseCharge1,
    leaseCharge2,
    InitialLeaseType,
    FinalLeaseType,
    sourceRecord,
    chargeCategory,
    unitCost,
    nihRate,
    quantity,
    totalCost,
    investigatorId,
    creditAccount,
    creditAccountType,
    comment,
    creditAccountId,
    rateId,
    exemptionId,
    isMiscCharge,
    isAdjustment
FROM lease_final
UNION ALL
SELECT
    id,
    date,
    enddate,
    dateFinalized,
    project,
    account,
    projectedReleaseCondition,
    releaseCondition,
    assignCondition,
    releaseType,
    ageAtTime,
    category,
    chargeId,
    serviceCenter,
    item,
    leaseCharge1,
    leaseCharge2,
    InitialLeaseType,
    FinalLeaseType,
    sourceRecord,
    chargeCategory,
    unitCost,
    nihRate,
    quantity,
    totalCost,
    investigatorId,
    creditAccount,
    creditAccountType,
    comment,
    creditAccountId,
    rateId,
    exemptionId,
    isMiscCharge,
    isAdjustment
FROM misc_charges;
