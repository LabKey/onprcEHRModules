SELECT
  p.*,
  coalesce(e.unitcost, cr.unitcost) as unitcost,
  CASE
    WHEN e.unitcost IS NOT NULL THEN 'Y'
    ELSE null
  END as isExemption

FROM onprc_billing.leaseFees p

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