SELECT
  i.invoiceId,
  i.project,
  count(i.invoiceId) as total,
  sum(i.totalCost) as totalCost,

FROM onprc_billing.invoicedItems i

GROUP BY i.invoiceId, i.project