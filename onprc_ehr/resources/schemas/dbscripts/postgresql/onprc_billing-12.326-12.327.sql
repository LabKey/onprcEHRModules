ALTER TABLE onprc_billing.invoicedItems DROP COLUMN transactionNumber;
ALTER TABLE onprc_billing.invoicedItems ADD transactionNumber varchar(100);
