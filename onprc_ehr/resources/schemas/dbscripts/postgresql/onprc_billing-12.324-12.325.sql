ALTER TABLE onprc_billing.labworkFeeDefinition DROP COLUMN chargeType;
ALTER TABLE onprc_billing.labworkFeeDefinition ADD chargeType varchar(100);