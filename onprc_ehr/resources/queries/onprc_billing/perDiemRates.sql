SELECT
  p.*,
  coalesce(e.unitcost, cr.unitcost) as unitcost,
  CASE
    WHEN e.unitcost IS NOT NULL THEN 'Y'
    ELSE null
  END as isExemption

FROM onprc_billing.perDiems p

LEFT JOIN onprc_billing.chargeRates cr ON (
    p.startdate >= cr.startDate AND
    p.startdate <= cr.enddateTimeCoalesced AND
    p.chargeId = cr.chargeId
)

LEFT JOIN onprc_billing.chargeRateExemptions e ON (
    p.startdate >= e.startDate AND
    p.startdate <= e.enddateTimeCoalesced AND
    p.chargeId = e.chargeId AND
    p.project = e.project
)