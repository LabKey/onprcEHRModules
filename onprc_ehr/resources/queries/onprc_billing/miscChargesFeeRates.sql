/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  p.Id,
  p.date,
  p.project,
  p.chargeId,
  coalesce(p.unitcost, e.unitcost, cr.unitcost) as unitcost,
  coalesce(p.quantity, 1) as quantity,
  coalesce(p.quantity, 1) * coalesce(p.unitcost, e.unitcost, cr.unitcost) as totalcost,
  p.category,
  p.chargeType,
  p.invoicedItemId,
  p.sourceRecord,
  p.comment,

  ce.account as creditAccount,
  ce.rowid as creditAccountId,
  CASE
    WHEN (p.unitcost IS NOT NULL OR e.unitcost IS NOT NULL) THEN 'Y'
    ELSE null
  END as isExemption,
  e.rowid as exemptionId,
  CASE WHEN e.rowid IS NULL THEN cr.rowid ELSE null END as rateId,

  --find assignment on this date
  CASE WHEN (SELECT count(*) as projects FROM study.assignment a WHERE
    p.Id = a.Id AND
    p.project = a.project AND
    (cast(p.date AS DATE) < a.enddateCoalesced OR a.enddate IS NULL) AND
    p.date >= a.dateOnly
  ) > 0 THEN true ELSE false END as matchesProject

FROM onprc_billing.miscChargesFees p

LEFT JOIN onprc_billing.chargeRates cr ON (
  p.date >= cr.startDate AND
  p.date <= cr.enddateTimeCoalesced AND
  p.chargeId = cr.chargeId
)

LEFT JOIN onprc_billing.chargeRateExemptions e ON (
  p.date >= e.startDate AND
  p.date <= e.enddateTimeCoalesced AND
  p.chargeId = e.chargeId AND
  p.project = e.project
)

LEFT JOIN onprc_billing.creditAccount ce ON (
  p.date >= ce.startDate AND
  p.date <= ce.enddateTimeCoalesced AND
  p.chargeId = ce.chargeId
)