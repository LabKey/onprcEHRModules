SELECT
  p.*,
  coalesce(e.unitcost, cr.unitcost) as unitcost,
  CASE
    WHEN e.unitcost IS NOT NULL THEN 'Exemption'
    ELSE null
  END as isExemption

FROM onprc_billing.perDiems p

LEFT JOIN onprc_billing.chargeRates cr ON (
    p.startDate >= cr.startDate AND
    p.startDate <= cr.enddateTimeCoalesced AND
    p.chargeId = cr.chargeId
)

LEFT JOIN onprc_billing.chargeRateExemptions e ON (
    p.startDate >= e.startDate AND
    p.startDate <= e.enddateTimeCoalesced AND
    p.chargeId = e.chargeId AND
    p.project = e.project
)