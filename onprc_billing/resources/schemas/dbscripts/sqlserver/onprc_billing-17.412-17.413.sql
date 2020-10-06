-- Adds change inflation rate to 3 position decimal
-- add primary key and identity key
alter table [onprc_billing].[AnnualRateChange]
ALTER COLUMN InflationRate Numeric(18,4)