SELECT
  i.invoiceId,
  i.item,
  count(i.invoiceId) as numItems,
  sum(i.totalCost) as totalCost,

FROM onprc_billing.invoicedItems i

GROUP BY i.invoiceId, i.item