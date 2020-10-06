-- Adds table Annual Rate Change to Billing
-- add primary key and identity key
ALTER TABLE onprc_billing.AnnualRateChange Add RowID Int IDENTITY (1,1)not null;
ALTER TABLE onprc_billing.AnnualRateChange Add CONSTRAINT PK_AnnualRateChange_RowID PRIMARY KEY CLUSTERED (RowID);
