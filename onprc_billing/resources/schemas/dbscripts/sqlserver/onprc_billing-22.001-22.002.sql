EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'Originating Agency Award Number';
GO
ALTER TABLE onprc_billing.aliases ADD [OriginatingAgencyAwareNum] VarChar(255) Null;
