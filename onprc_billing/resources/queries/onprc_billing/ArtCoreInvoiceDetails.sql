/*Added 2026-10-20 Art Core using Linked Schema data*/
    PARAMETERS (StartDate TIMESTAMP, EndDate TIMESTAMP)
SELECT
       r.rowID,
       ii.transactionNumber,
       ii.Id,
       ii.date,
       ii.item,

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
       ii.chargecategory,

FROM ArtCoreInvoicedDetails.invoicedItems ii left join invoiceRuns r on ii.invoiceid = r.objectId
WHERE ii.date >= StartDate
  AND ii.date < TIMESTAMPADD('SQL_TSI_DAY', 1, EndDate)