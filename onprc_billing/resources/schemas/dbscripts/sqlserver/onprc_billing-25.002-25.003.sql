EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'OGA_AWARD_START_DATE';
GO
EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'IndirectRate';
GO
GOEXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'OGA_AWARD_END_DATE';
GO
EXEC core.fn_dropifexists 'ogaSynch', 'onprc_billing', 'COLUMN', 'OGA_AWARD_START_DATE';
GO
EXEC core.fn_dropifexists 'ogaSynch', 'onprc_billing', 'COLUMN', 'OGA_AWARD_END_DATE';
GO
EXEC core.fn_dropifexists 'ogaSynch', 'onprc_billing', 'COLUMN', 'IndirectRate';
GO
ALTER TABLE onprc_billing.aliases ADD [	OGA_AWARD_START_DATE]  DATE Null;
GO
ALTER TABLE onprc_billing.aliases ADD [OGA_AWARD_END_DATE] DATE Null;
GO
ALTER TABLE onprc_billing.ogaSynch ADD [OGA_AWARD_START_DATE] DATE Null;
GO
ALTER TABLE onprc_billing.ogaSynch ADD [OGA_AWARD_END_DATE] DATE Null;
GO
ALTER TABLE onprc_billing.ogaSynch ADD [IndirectRate] FLOAT Null;
GO
ALTER TABLE onprc_billing.aliases ADD [IndirectRate] FLOAT Null;
GO