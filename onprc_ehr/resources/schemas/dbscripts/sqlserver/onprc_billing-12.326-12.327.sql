ALTER TABLE onprc_billing.invoicedItems DROP COLUMN transactionNumber;
GO
ALTER TABLE onprc_billing.invoicedItems ADD transactionNumber varchar(100);
