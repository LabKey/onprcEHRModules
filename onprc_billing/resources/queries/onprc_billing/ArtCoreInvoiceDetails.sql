PARAMETERS (StartDate TIMESTAMP, EndDate TIMESTAMP)
SELECT
    ir.rowId,
    ii.transactionNumber,
    ii.Id,
    ii.date,
    ii.item,
    ii.itemCode,
    ii.category,
    ii.servicecenter,
    ii.project,
    ii.debitedaccount,
    ii.creditedaccount,

    ii.lastName,
    ii.firstName,
    ii.quantity,
    ii.unitCost,
    ii.totalcost,
    ii.comment,
    ii.chargecategory

FROM invoicedItems ii left outer join invoiceRuns ir on ii.invoiceID = ir.objectID
WHERE ii.date >= StartDate
  AND ii.date < TIMESTAMPADD('SQL_TSI_DAY', 1, EndDate)
    and ii.category = 'ART Core'