USE [Labkey_upgrade]
GO
IF OBJECT_ID('onprc_billing.annualinflationrate', 'U') IS NOT NULL
DROP TABLE onprc_billing.annualinflationrate;