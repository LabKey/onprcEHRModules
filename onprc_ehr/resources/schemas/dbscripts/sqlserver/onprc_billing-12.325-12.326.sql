ALTER TABLE onprc_billing.invoicedItems ADD transactionNumber int;

ALTER TABLE onprc_billing.miscCharges ADD chargeType int;
ALTER TABLE onprc_billing.miscCharges ADD billingDate datetime;
ALTER TABLE onprc_billing.miscCharges ADD invoiceId entityid;
ALTER TABLE onprc_billing.miscCharges ADD description varchar(4000);
ALTER TABLE onprc_billing.miscCharges DROP COLUMN descrption;