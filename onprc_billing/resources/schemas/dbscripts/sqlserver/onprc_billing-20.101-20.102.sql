-- Adds change inflation rate to 3 position decimal
-- add primary key and identity key
--If the field exists in the current build we drop the column and recreate
EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'COMMENTS';
GO
ALTER TABLE onprc_billing.aliases ADD [COMMENTS] VarChar(255) Null;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'dateDisabled';
GO
ALTER TABLE onprc_billing.aliases ADD [dateDisabled] DATETIME Null;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'PPQNumber';
GO
ALTER TABLE onprc_billing.aliases ADD [PPQNumber] VARCHAR(25) NUll;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'PPQDate';
GO
ALTER TABLE onprc_billing.aliases ADD [PPQDate] DATETIME Null;
