EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'Originating Agency Award Number';
GO
ALTER TABLE onprc_billing.aliases ADD [OriginatingAgencyAwardNum] VarChar(255) Null;
GO
ALTER TABLE onprc_billing.ogaSynch ADD [ORIGINATING_AGENCY_AWARD_NUM] VarChar(255) Null;