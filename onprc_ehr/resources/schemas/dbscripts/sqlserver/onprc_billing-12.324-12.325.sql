ALTER TABLE onprc_billing.labworkFeeDefinition DROP COLUMN chargeType;
GO
ALTER TABLE onprc_billing.labworkFeeDefinition ADD chargeType varchar(100);