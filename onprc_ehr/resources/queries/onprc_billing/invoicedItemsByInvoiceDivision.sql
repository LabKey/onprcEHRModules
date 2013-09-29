SELECT
  i.invoiceId,
  i.investigatorId.division,

  sum(i.quantity) as numItems,
  sum(i.totalCost) as total

FROM onprc_billing.invoicedItems i

GROUP BY i.invoiceId, i.investigatorId.division