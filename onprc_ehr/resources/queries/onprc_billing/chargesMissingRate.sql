PARAMETERS (Date TIMESTAMP)

SELECT
  ci.rowid,
  ci.name,
  ci.category,
  r.rowid as rateId,
  ca.rowid as creditAccountId
FROM onprc_billing.chargeableItems ci
LEFT JOIN onprc_billing.chargeRates r ON (r.chargeId = ci.rowid AND CAST(Date as DATE) >= cast(r.startDate as date) AND CAST(Date as DATE) <= r.enddateCoalesced)
LEFT JOIN onprc_billing.creditAccount ca ON (ca.chargeId = ci.rowid AND CAST(Date as DATE) >= cast(ca.startDate as date) AND CAST(Date as DATE) <= ca.enddateCoalesced)
where ci.active = true and (r.rowid is null OR ca.rowid is null)