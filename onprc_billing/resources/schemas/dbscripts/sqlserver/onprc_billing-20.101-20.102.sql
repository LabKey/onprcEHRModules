-- Adds change inflation rate to 3 position decimal
-- add primary key and identity key
--If the field exists in the current build we drop the column and recreate
ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [COMMENTS];
ALTER TABLE onprc_billing.aliases ADD [COMMENTS] VarChar(255) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [dateDisabled];
ALTER TABLE onprc_billing.aliases ADD [dateDisabled] DATETIME Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [PPQNumber];
ALTER TABLE onprc_billing.aliases ADD [PPQNumber] VARCHAR(25) NUll;
ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [PPQDate];
ALTER TABLE onprc_billing.aliases ADD [PPQDate] DATETIME Null;
