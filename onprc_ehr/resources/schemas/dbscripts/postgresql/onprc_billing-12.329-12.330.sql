ALTER TABLE onprc_billing.invoiceRuns DROP COLUMN runBy;
ALTER TABLE onprc_billing.invoiceRuns DROP COLUMN date;

ALTER TABLE onprc_billing.invoiceRuns ADD invoiceNumber varchar(200);

ALTER TABLE onprc_billing.miscCharges ADD invoicedItemId entityid;
ALTER TABLE onprc_billing.miscCharges DROP COLUMN description;