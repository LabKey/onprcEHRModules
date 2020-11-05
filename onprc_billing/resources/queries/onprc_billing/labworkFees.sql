PARAMETERS(StartDate TIMESTAMP, EndDate TIMESTAMP)

SELECT
  e.Id,
  e.date,
  e.billingDate,
  e.project,
  e.servicerequested,
  p.chargeId,
  e.sourceRecord,
  null as chargeCategory,
  e.taskid

FROM onprc_billing.clinPathRun_ExemptCharges e
JOIN onprc_billing.labworkFeeDefinition p ON (p.servicename = e.servicerequested AND p.active = true)

WHERE CAST(e.billingdate as date) >= CAST(StartDate as date) AND CAST(e.billingdate as date) <= CAST(EndDate as date)
AND (e.chargetype not in ('Not Billable', 'No Charge', 'Research Staff') or e.chargetype is null)
AND e.qcstate.publicdata = true

UNION ALL

--for any service sent to an outside lab, we have 1 processing charge per distinct sample
SELECT
  e.Id,
  e.date,
  e.billingDate,
  e.project,
  group_concat(e.servicerequested) as servicerequested,
 (SELECT c.rowid FROM onprc_billing_public.chargeableItems c WHERE c.name = 'Lab Processing Fee') as chargeId,
  null as sourceRecord,
  null as chargeCategory,
  e.taskid

FROM onprc_billing.clinPathRun_ExemptCharges e
WHERE CAST(e.billingDate as date) >= CAST(StartDate as date) AND CAST(e.billingDate as date) <= CAST(EndDate as date)
AND e.qcstate.publicdata = true
AND (e.chargetype not in ('Not Billable', 'No Charge', 'Research Staff') or e.chargetype is null)
AND e.servicerequested.outsidelab = true
GROUP BY e.Id, e.date, e.billingdate, e.project, e.tissue, e.taskid