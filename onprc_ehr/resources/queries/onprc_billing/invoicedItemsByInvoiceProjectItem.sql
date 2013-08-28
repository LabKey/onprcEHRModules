SELECT
  i.invoiceId,
  i.project,
  i.item,

  sum(i.quantity) as quantity,
  sum(i.totalCost) as totalCost,

FROM onprc_billing.invoicedItems i

GROUP BY i.invoiceId, i.project, i.item