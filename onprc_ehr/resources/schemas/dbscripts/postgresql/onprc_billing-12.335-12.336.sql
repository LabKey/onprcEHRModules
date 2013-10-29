ALTER TABLE onprc_billing.grants ADD rowid serial;
ALTER TABLE onprc_billing.grants ADD container entityid;

ALTER TABLE onprc_billing.grants DROP CONSTRAINT PK_grants;
ALTER TABLE onprc_billing.grants ADD CONSTRAINT PK_grants PRIMARY KEY (rowid);
ALTER TABLE onprc_billing.grants ADD CONSTRAINT UNIQUE_grants UNIQUE (container, grantNumber);

ALTER TABLE onprc_billing.grants DROP COLUMN totalDCBudget;
ALTER TABLE onprc_billing.grants DROP COLUMN totalFABudget;