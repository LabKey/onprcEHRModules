SELECT
  r.rowid,
  r.runDate,
  r.billingPeriodStart,
  r.billingPeriodEnd,
  r.invoiceNumber,
  r.comment,
  r.objectid
FROM onprc_billing.invoiceRuns r
where r.status = 'Finalized'