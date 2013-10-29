SELECT
  i.rowId,
  i.invoiceId,
  i.transactionNumber,
  i.invoiceDate,
  i.Id,
  i.item,
  i.date,
  i.itemCode,
  i.category,
  i.servicecenter,
  i.project,
  i.debitedaccount,
  i.creditedaccount,
  i.faid,
  i.investigatorId,
  i.firstName,
  i.lastName,
  i.department,
  i.mailcode,
  i.contactPhone,
  i.chargeId,
  i.objectid,
  i.quantity,
  i.unitCost,
  i.totalcost

FROM onprc_billing.invoicedItems i
WHERE i.invoiceId.status = 'Finalized' AND (SELECT max(rowid) as expr FROM onprc_billing.dataAccess da WHERE isMemberOf(da.userid) AND (
    da.allData = true OR
    (da.project = i.project) OR
    da.investigatorId = i.investigatorId
  )) IS NOT NULL OR isMemberOf(i.project.investigatorId.userid) OR isMemberOf(i.project.investigatorId.financialAnalyst)

