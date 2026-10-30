PARAMETERS (StartDate TIMESTAMP, EndDate TIMESTAMP)
SELECT
    ir.rowId,
    ii.transactionNumber,
    ii.Id,
    ii.date,
    ii.item,
    ii.category,
    ii.servicecenter,
    ii.debitedaccount,
    a.faSchedule,
    a.AliasType,
    ii.creditedaccount,
    ii.lastName as PI_LastName,
    ii.firstName as PI_FirstName,
    ii.quantity,
    ii.unitCost,
    ii.totalcost,
    ii.comment


FROM invoicedItems ii left outer join invoiceRuns ir on ii.invoiceID = ir.objectID
        Left join aliases a on a.alias = ii.debitedaccount
WHERE ii.date >= StartDate
  AND ii.date < TIMESTAMPADD('SQL_TSI_DAY', 1, EndDate)
    and ii.category = 'ART Core'