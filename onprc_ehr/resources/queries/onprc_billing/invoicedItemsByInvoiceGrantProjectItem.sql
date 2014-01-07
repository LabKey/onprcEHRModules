SELECT
  i.invoiceId,
  i.debitedaccount.projectNumber,
  i.item,

  sum(i.quantity) as numItems,
  sum(i.totalCost) as total

FROM onprc_billing.invoicedItems i

GROUP BY i.invoiceId, i.debitedaccount.projectNumber, i.item