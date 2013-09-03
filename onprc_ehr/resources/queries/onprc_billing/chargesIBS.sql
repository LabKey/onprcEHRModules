SELECT
  i.servicecenter,
  'N' as transactionType,
  i.date as transactionDate,
  i.item as transactionDescription,
  i.lastName,
  i.firstName,
  null as fiscalAuthorityNumber,
  i.faid,
  null as fiscalAuthorityName,
  i.department,
  i.mailcode,
  i.contactPhone,
  null as itemCode,
  i.quantity,
  i.unitCost as price,
  i.debitedaccount as OSUAlias,
  --i.creditedaccount,
  i.totalcost,
  i.invoiceDate,
  i.invoiceId as invoiceNumber

FROM onprc_billing.invoicedItems i

UNION ALL

SELECT
  i.servicecenter,
  'N' as transactionType,
  i.date as transactionDate,
  i.item as transactionDescription,
  i.lastName,
  i.firstName,
  null as fiscalAuthorityNumber,
  i.faid,
  null as fiscalAuthorityName,
  i.department,
  i.mailcode,
  i.contactPhone,
  null as itemCode,
  i.quantity,
  i.unitCost as price,
  --i.debitedaccount as OSUAlias,
  i.creditedaccount as OSUAlias,
  (i.totalcost * -1) as totalcost,
  i.invoiceDate,
  i.invoiceId as invoiceNumber

FROM onprc_billing.invoicedItems i
