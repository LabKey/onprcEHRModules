/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  p.Id,
  p.date,
  p.billingDate,
  p.project,
  coalesce(p.debitedaccount, p.project.account) as account,
  p.chargeId,
  coalesce(p.chargeId.name, p.item) as item,
  coalesce(p.unitCost, e.unitCost, cr.unitCost) as unitCost,
  coalesce(p.quantity, 1) as quantity,
  coalesce(p.quantity, 1) * coalesce(p.unitCost, e.unitCost, cr.unitCost) as totalcost,
  coalesce(p.category, p.chargeId.category) as category,
  p.chargeType,
  p.invoicedItemId,
  p.sourceRecord,
  p.comment,
  p.sourceRecord as objectid,

  coalesce(p.creditedaccount, ce.account) as creditAccount,
  CASE
    WHEN p.creditedaccount IS NULL THEN ce.rowid
    ELSE NULL
  END as creditAccountId,
  CASE
    WHEN (p.unitCost IS NOT NULL OR e.unitCost IS NOT NULL) THEN 'Y'
    ELSE null
  END as isExemption,
  CASE
    WHEN (p.unitCost IS NULL AND e.unitCost IS NULL AND cr.unitCost IS NULL) THEN 'Y'
    ELSE null
  END as lacksRate,
  e.rowid as exemptionId,
  CASE WHEN e.rowid IS NULL THEN cr.rowid ELSE null END as rateId,

  --find assignment on this date
  CASE
    WHEN p.project IS NULL THEN 'N'
    WHEN p.project.alwaysavailable = true THEN null
    WHEN (SELECT count(*) as projects FROM study.assignment a WHERE
      p.Id = a.Id AND
      p.project = a.project AND
      (cast(p.date AS DATE) < a.enddateCoalesced OR a.enddate IS NULL) AND
      p.date >= a.dateOnly
    ) > 0 THEN null
    ELSE 'N'
  END as matchesProject,
  (SELECT group_concat(distinct a.project.displayName, chr(10)) as projects FROM study.assignment a WHERE
    p.Id = a.Id AND
    p.project = a.project AND
    (cast(p.date AS DATE) < a.enddateCoalesced OR a.enddate IS NULL) AND
    p.date >= a.dateOnly
  ) as assignmentAtTime,
  p.container,
  CASE WHEN p.project.account IS NULL THEN 'Y' ELSE null END as isMissingAccount,
  CASE
    WHEN ifdefined(p.project.account.aliasEnabled) IS NULL THEN null
    WHEN (ifdefined(p.project.account.aliasEnabled) IS NULL OR ifdefined(p.project.account.aliasEnabled) != 'Y') THEN 'Y'
    ELSE null
  END as isExpiredAccount

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