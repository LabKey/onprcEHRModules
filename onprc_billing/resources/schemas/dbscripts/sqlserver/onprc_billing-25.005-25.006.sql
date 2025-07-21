--This update allows the endDate field to be NULL
--Revised 2025-06-30
ALTER TABLE onprc_billing.IndirectRates
ALTER COLUMN EndDate DATETIME NULL;
