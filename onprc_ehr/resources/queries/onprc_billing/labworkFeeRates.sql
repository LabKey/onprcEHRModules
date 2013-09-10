SELECT
  p.*,
  coalesce(e.unitcost, cr.unitcost) as unitcost,
  ce.account,
  ce.rowid as creditAccountId,
  CASE
    WHEN e.unitcost IS NOT NULL THEN 'Y'
    ELSE null
  END as isExemption

FROM onprc_billing.labworkFees p

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