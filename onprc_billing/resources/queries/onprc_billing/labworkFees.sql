
PARAMETERS (StartDate TIMESTAMP, EndDate TIMESTAMP)

-- Direct charges (internal labwork) by evaluation date
SELECT
    e.Id,
    e.date,
    e.billingDate,
    e.project,
    e.serviceRequested,
    p.chargeId,
    e.sourceRecord,
    NULL AS chargeCategory,
    e.taskId
FROM onprc_billing.clinPathRun_ExemptCharges e
         JOIN onprc_billing.labworkFeeDefinition p
              ON p.serviceName = e.serviceRequested
                  AND p.active = TRUE
WHERE CAST(e.date AS DATE) BETWEEN CAST(StartDate AS DATE) AND CAST(EndDate AS DATE)
  AND e.qcState = 18
  AND (e.chargeType NOT IN ('Not Billable', 'No Charge', 'Research Staff') OR e.chargeType IS NULL)

UNION ALL

-- Processing fee: 1 per distinct sample sent to outside labs
SELECT
    e.Id,
    e.date,
    e.billingDate,
    e.project,
    GROUP_CONCAT(DISTINCT e.serviceRequested) AS serviceRequested,
    (
        SELECT c.rowId
        FROM onprc_billing_public.chargeableItems c
        WHERE c.name = 'Lab Processing Fee'
    ) AS chargeId,
    NULL AS sourceRecord,
    NULL AS chargeCategory,
    e.taskId
FROM onprc_billing.clinPathRun_ExemptCharges e
WHERE CAST(e.date AS DATE) BETWEEN CAST(StartDate AS DATE) AND CAST(EndDate AS DATE)
  AND e.qcState = 18
  AND (e.chargeType NOT IN ('Not Billable', 'No Charge', 'Research Staff') OR e.chargeType IS NULL)
  AND e.serviceRequested.outsideLab = TRUE
GROUP BY
    e.Id,
    e.date,
    e.billingDate,
    e.project,
    e.tissue,
    e.taskId;
