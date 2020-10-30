-- Adding additional Fields for Alias insert from OGA Synch
--Rerunning and it does not appear in Build
--2020-03-4 Revision to add this to UAT
ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [ApplicationType];
ALTER TABLE onprc_billing.aliases ADD [ApplicationType] VarChar(255) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [ApplicationTypeDescription];
ALTER TABLE onprc_billing.aliases ADD [ApplicationTypeDescription]  VarChar(255) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [AwardStatus];
ALTER TABLE onprc_billing.aliases ADD [AwardStatus] VARCHAR(100) NUll;
ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [AwardID];
ALTER TABLE onprc_billing.aliases ADD [AwardID] VARCHAR(100) NUll;
ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [ApplicationType];
ALTER TABLE onprc_billing.aliases ADD [ApplicationType] VARCHAR(255) NUll;
ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [ProjectID];
ALTER TABLE onprc_billing.aliases ADD [ProjectID] VARCHAR(100) NUll;
ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [ActivityType];
ALTER TABLE onprc_billing.aliases ADD [ActivityType] VARCHAR(255) NUll;
ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [AwardNumber];
ALTER TABLE onprc_billing.aliases ADD [AwardNumber] VARCHAR(255) NUll;
ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [AwardSuffix];
ALTER TABLE onprc_billing.aliases ADD [AwardSuffix] VARCHAR(255) NUll;
ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [Org];
ALTER TABLE onprc_billing.aliases ADD [Org] VARCHAR(255) NUll;
ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [ADFMEmpNum];
ALTER TABLE onprc_billing.aliases ADD [ADFMEmpNum] VARCHAR(255) NUll;
ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [ADFMFullName];
ALTER TABLE onprc_billing.aliases ADD [ADFMFullName] VARCHAR(255) NUll;
ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [ActivityTypeDescription];
ALTER TABLE onprc_billing.aliases ADD [ActivityTypeDescription] VARCHAR(255) NUll;
ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [FundingSourceNumber];
ALTER TABLE onprc_billing.aliases ADD [FUndingSourceNumber] VARCHAR(255) NUll
ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [FundingSourceName];
ALTER TABLE onprc_billing.aliases ADD [FUndingSourceName] VARCHAR(255) NUll
ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS [Org];
ALTER TABLE onprc_billing.aliases ADD [Org] VARCHAR(255) NUll

--Adding additional fields to OGA Synch
