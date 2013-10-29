ALTER TABLE onprc_billing.grantProjects ADD protocolNumber Varchar(100);
ALTER TABLE onprc_billing.grantProjects ADD projectStatus Varchar(100);
ALTER TABLE onprc_billing.grantProjects ADD aliasEnabled Varchar(100);
ALTER TABLE onprc_billing.grantProjects ADD ogaProjectId int;

ALTER TABLE onprc_billing.grantProjects DROP COLUMN spid;
ALTER TABLE onprc_billing.grantProjects DROP COLUMN currentDCBudget;
ALTER TABLE onprc_billing.grantProjects DROP COLUMN currentFABudget;
ALTER TABLE onprc_billing.grantProjects DROP COLUMN totalDCBudget;
ALTER TABLE onprc_billing.grantProjects DROP COLUMN totalFABudget;
ALTER TABLE onprc_billing.grantProjects DROP COLUMN awardStartDate;
ALTER TABLE onprc_billing.grantProjects DROP COLUMN awardEndDate;
ALTER TABLE onprc_billing.grantProjects DROP COLUMN currentYear;
ALTER TABLE onprc_billing.grantProjects DROP COLUMN totalYears;
ALTER TABLE onprc_billing.grantProjects DROP COLUMN awardSuffix;

ALTER TABLE onprc_billing.grants ADD awardStatus Varchar(100);
ALTER TABLE onprc_billing.grants ADD applicationType Varchar(100);
ALTER TABLE onprc_billing.grants ADD activityType Varchar(100);

ALTER TABLE onprc_billing.grants ADD ogaAwardId int;

ALTER TABLE onprc_billing.fiscalAuthorities ADD employeeId varchar(100);