SELECT
  i.invoiceId,
  i.creditedaccount,
  count(i.invoiceId) as numItems,
  sum(i.totalCost) as totalCost

FROM onprc_billing.invoicedItems i

GROUP BY i.invoiceId, i.creditedaccount