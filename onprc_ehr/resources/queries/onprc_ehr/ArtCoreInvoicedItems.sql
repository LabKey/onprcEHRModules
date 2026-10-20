/*Added 2026-10-20 Art Core using Linked Schema data*/
PARAMETERS (StartDate TIMESTAMP, EndDate TIMESTAMP)
SELECT
    i.invoiceId,
    r.
    i.date,
    i.Id as NHPID,
    i.item,
    i.category,
    i.quantity,
    i.unitCost,
    i.totalCost,
    i.debitedAccount,
    i.creditedAccount
FROM ArtCoreInvoicedItems.invoicedItems i
            LEFT JOIN ArtCoreInvoicedItems.iNVOICErUNS R ON R.oBJECTid = i.invoiceId
WHERE i.date >= StartDate
  AND i.date < TIMESTAMPADD('SQL_TSI_DAY', 1, EndDate)