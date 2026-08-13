-- Adding additional Fields for Alias insert from OGA Synch
--Rerunning and it does not appear in Build
--2020-03-4 Revision to add this to UAT
EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'ApplicationType';
GO
ALTER TABLE onprc_billing.aliases ADD [ApplicationType] VarChar(255) Null;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'ApplicationTypeDescription';
GO
ALTER TABLE onprc_billing.aliases ADD [ApplicationTypeDescription]  VarChar(255) Null;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'AwardStatus';
GO
ALTER TABLE onprc_billing.aliases ADD [AwardStatus] VARCHAR(100) NUll;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'AwardID';
GO
ALTER TABLE onprc_billing.aliases ADD [AwardID] VARCHAR(100) NUll;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'ApplicationType';
GO
ALTER TABLE onprc_billing.aliases ADD [ApplicationType] VARCHAR(255) NUll;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'ProjectID';
GO
ALTER TABLE onprc_billing.aliases ADD [ProjectID] VARCHAR(100) NUll;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'ActivityType';
GO
ALTER TABLE onprc_billing.aliases ADD [ActivityType] VARCHAR(255) NUll;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'AwardNumber';
GO
ALTER TABLE onprc_billing.aliases ADD [AwardNumber] VARCHAR(255) NUll;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'AwardSuffix';
GO
ALTER TABLE onprc_billing.aliases ADD [AwardSuffix] VARCHAR(255) NUll;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'Org';
GO
ALTER TABLE onprc_billing.aliases ADD [Org] VARCHAR(255) NUll;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'ADFMEmpNum';
GO
ALTER TABLE onprc_billing.aliases ADD [ADFMEmpNum] VARCHAR(255) NUll;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'ADFMFullName';
GO
ALTER TABLE onprc_billing.aliases ADD [ADFMFullName] VARCHAR(255) NUll;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'ActivityTypeDescription';
GO
ALTER TABLE onprc_billing.aliases ADD [ActivityTypeDescription] VARCHAR(255) NUll;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'FundingSourceNumber';
GO
ALTER TABLE onprc_billing.aliases ADD [FUndingSourceNumber] VARCHAR(255) NUll

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'FundingSourceName';
GO
ALTER TABLE onprc_billing.aliases ADD [FUndingSourceName] VARCHAR(255) NUll

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'Org';
GO
ALTER TABLE onprc_billing.aliases ADD [Org] VARCHAR(255) NUll

--Adding additional fields to OGA Synch
