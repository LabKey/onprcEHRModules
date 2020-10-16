/*
 * Copyright (c) 2012 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
CREATE SCHEMA onprc_billing;
GO
;

--this table contains one row each time a billing run is performed, which gleans items to be charged from a variety of sources
--and snapshots them into invoicedItems
CREATE TABLE onprc_billing.invoiceRuns (
    rowId INT IDENTITY (1,1) NOT NULL,
    date DATETIME,
    dataSources varchar(1000),
    runBy userid,
    comment varchar(4000),

    container ENTITYID NOT NULL,
    createdBy USERID,
    created DATETIME,
    modifiedBy USERID,
    modified DATETIME,

    CONSTRAINT PK_invoiceRuns PRIMARY KEY (rowId)
);

--this table contains a snapshot of items actually invoiced, which will draw from many places in the animal record
CREATE TABLE onprc_billing.invoicedItems (
    rowId INT IDENTITY (1,1) NOT NULL,
    id varchar(100),
    date DATETIME,
    debitedaccount varchar(100),
    creditedaccount varchar(100),
    category varchar(100),
    item varchar(500),
    quantity double precision,
    unitcost double precision,
    totalcost double precision,
    chargeId int,
    rateId int,
    exemptionId int,
    comment varchar(4000),
    flag integer,
    sourceRecord varchar(200),
    billingId int,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created DATETIME,
    modifiedBy USERID,
    modified DATETIME,

    CONSTRAINT PK_billedItems PRIMARY KEY (rowId)
);


--this table contains a list of all potential items that can be charged.  it maps between the integer ID
--and a descriptive name.  it does not contain any fee information
CREATE TABLE onprc_billing.chargableItems (
    rowId INT IDENTITY (1,1) NOT NULL,
    name varchar(200),
    category varchar(200),
    comment varchar(4000),
    active bit default 1,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created DATETIME,
    modifiedBy USERID,
    modified DATETIME,

    CONSTRAINT PK_chargableItems PRIMARY KEY (rowId)
);

--this table contains a list of the current changes for each item in onprc_billing.charges
--it will retain historic information, so we can accurately determine 'cost at the time'
CREATE TABLE onprc_billing.chargeRates (
    rowId INT IDENTITY (1,1) NOT NULL,
    chargeId int,
    unitcost double precision,
    unit varchar(100),
    startDate datetime,
    endDate datetime,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created DATETIME,
    modifiedBy USERID,
    modified DATETIME,

    CONSTRAINT PK_chargeRates PRIMARY KEY (rowId)
);

--contains records of project-specific exemptions to chargeRates
CREATE TABLE onprc_billing.chargeRateExemptions (
    rowId INT IDENTITY (1,1) NOT NULL,
    project int,
    chargeId int,
    unitcost double precision,
    unit varchar(100),
    startDate datetime,
    endDate datetime,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created DATETIME,
    modifiedBy USERID,
    modified DATETIME,

    CONSTRAINT PK_chargeRateExemptions PRIMARY KEY (rowId)
);

--maps the account to be credited for each charged item
CREATE TABLE onprc_billing.creditAccount (
    rowId INT IDENTITY (1,1) NOT NULL,
    chargeId int,
    account int,
    startDate datetime,
    endDate datetime,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created DATETIME,
    modifiedBy USERID,
    modified DATETIME,

    CONSTRAINT PK_creditAccount PRIMARY KEY (rowId)
);

--this table contains records of misc charges that have happened that cannot otherwise be
--automatically inferred from the record
CREATE TABLE onprc_billing.miscCharges (
    rowId INT IDENTITY (1,1) NOT NULL,
    id varchar(100),
    date DATETIME,
    project integer,
    account varchar(100),
    category varchar(100),
    chargeId int,
    descrption varchar(1000), --usually null, allow other random values to be supported
    quantity double precision,
    unitcost double precision,
    totalcost double precision,
    comment varchar(4000),

    taskid entityid,
    requestid entityid,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created DATETIME,
    modifiedBy USERID,
    modified DATETIME,

    CONSTRAINT PK_miscCharges PRIMARY KEY (rowId)
);


--this table details how to calculate lease fees, and produces a list of charges over a billing period
--no fee info is contained
CREATE TABLE onprc_billing.leaseFeeDefinition (
    rowId INT IDENTITY (1,1) NOT NULL,
    minAge int,
    maxAge int,

    assignCondition int,
    releaseCondition int,
    chargeId int,

    active bit default 1,
    objectid ENTITYID,
    createdBy int,
    created DATETIME,
    modifiedBy int,
    modified DATETIME,

    CONSTRAINT PK_leaseFeeDefinition PRIMARY KEY (rowId)
);

--this table details how to calculate lease fees, and produces a list of charges over a billing period
--no fee info is contained
CREATE TABLE onprc_billing.perDiemFeeDefinition (
    rowId INT IDENTITY (1,1) NOT NULL,
    chargeId int,
    housingType int,
    housingDefinition int,

    startdate datetime,
    releaseCondition int,

    active bit default 1,
    objectid ENTITYID,
    createdBy int,
    created DATETIME,
    modifiedBy int,
    modified DATETIME,

    CONSTRAINT PK_perDiemFeeDefinition PRIMARY KEY (rowId)
);

--creates list of all procedures that are billable
CREATE TABLE onprc_billing.clinicalFeeDefinition (
    rowId INT IDENTITY (1,1) NOT NULL,
    procedureId int,
    snomed varchar(100),

    active bit default 1,
    objectid ENTITYID,
    createdBy int,
    created DATETIME,
    modifiedBy int,
    modified DATETIME,

    CONSTRAINT PK_clinicalFeeDefinition PRIMARY KEY (rowId)
);

ALTER TABLE onprc_billing.chargeRates drop column unit;
ALTER TABLE onprc_billing.chargeRateExemptions drop column unit;

alter table onprc_billing.leaseFeeDefinition add project int;
alter table onprc_billing.chargableItems add shortName varchar(100);

CREATE TABLE onprc_billing.procedureFeeDefinition (
    rowid int identity(1,1),
    procedureId int,
    chargeType int,
    chargeId int,

    active bit default 1,
    objectid ENTITYID,
    createdBy int,
    created datetime,
    modifiedBy int,
    modified datetime,

    CONSTRAINT PK_procedureFeeDefinition PRIMARY KEY (rowId)
);

CREATE TABLE onprc_billing.financialContacts (
    rowid int identity(1,1),
    firstName varchar(100),
    lastName varchar(100),
    position varchar(100),
    address varchar(500),
    city varchar(100),
    state varchar(100),
    country varchar(100),
    zip varchar(100),
    phoneNumber varchar(100),

    active bit default 1,
    objectid ENTITYID,
    createdBy int,
    created datetime,
    modifiedBy int,
    modified datetime,

    CONSTRAINT PK_financialContacts PRIMARY KEY (rowId)
);

CREATE TABLE onprc_billing.grants (
    "grant" varchar(100),
    investigatorId int,
    title varchar(500),
    startDate datetime,
    endDate datetime,
    fiscalAuthority int,

    createdBy int,
    created datetime,
    modifiedBy int,
    modified datetime,

    CONSTRAINT PK_grants PRIMARY KEY ("grant")
);

CREATE TABLE onprc_billing.accounts (
    account varchar(100),
    "grant" varchar(100),
    investigator integer,
    startdate datetime,
    enddate datetime,
    externalid varchar(200),
    comment varchar(4000),
    fiscalAuthority int,
    tier integer,
    active bit default 1,

    objectid entityid,
    createdBy userid,
    created datetime,
    modifiedBy userid,
    modified datetime,

    CONSTRAINT PK_accounts PRIMARY KEY (account)
);

drop table onprc_billing.financialContacts;

CREATE TABLE onprc_billing.fiscalAuthorities (
    rowid int identity(1,1),
    faid varchar(100),
    firstName varchar(100),
    lastName varchar(100),
    position varchar(100),
    address varchar(500),
    city varchar(100),
    state varchar(100),
    country varchar(100),
    zip varchar(100),
    phoneNumber varchar(100),

    active bit default 1,
    objectid ENTITYID,
    createdBy int,
    created datetime,
    modifiedBy int,
    modified datetime,

    CONSTRAINT pk_fiscalAuthorities PRIMARY KEY (rowId)
);

CREATE TABLE onprc_billing.projectAccountHistory (
  rowid int identity(1,1),
  project int,
  account varchar(200),
  startdate datetime,
  enddate datetime,
  objectid entityid,
  createdby userid,
  created datetime,
  modifiedby userid,
  modified datetime
);

DROP TABLE onprc_billing.chargableItems;

CREATE TABLE onprc_billing.chargeableItems (
    rowId INT IDENTITY (1,1) NOT NULL,
    name varchar(200),
    shortName varchar(100),
    category varchar(200),
    comment varchar(4000),
    active bit default 1,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created DATETIME,
    modifiedBy USERID,
    modified DATETIME,

    CONSTRAINT PK_chargeableItems PRIMARY KEY (rowId)
);

ALTER TABLE onprc_billing.projectAccountHistory ADD CONSTRAINT PK_projectAccountHistory PRIMARY KEY  (rowid);

DROP TABLE onprc_billing.grants ;
GO

CREATE TABLE onprc_billing.grants (
    grantNumber varchar(100),
    investigatorId int,
    title varchar(500),
    startDate datetime,
    endDate datetime,
    fiscalAuthority int,
    fundingAgency varchar(200),
    grantType varchar(200),

    totalDCBudget double precision,
    totalFABudget double precision,
    budgetStartDate datetime,
    budgetEndDate datetime,

    agencyAwardNumber varchar(200),
    comment text,

    createdBy int,
    created datetime,
    modifiedBy int,
    modified datetime,

    CONSTRAINT PK_grants PRIMARY KEY (grantNumber)
);


DROP TABLE onprc_billing.accounts;

CREATE TABLE onprc_billing.grantProjects (
  rowid int identity(1,1),
  projectNumber varchar(200),
  grantNumber varchar(200),
  fundingAgency varchar(200),
  grantType varchar(200),
  agencyAwardNumber varchar(200),
  investigatorId int,
  alias varchar(200),
  projectTitle varchar(4000),
  projectDescription varchar(4000),
  currentYear int,
  totalYears int,
  awardSuffix varchar(200),
  organization varchar(200),

  awardStartDate datetime,
  awardEndDate datetime,
  budgetStartDate datetime,
  budgetEndDate datetime,
  currentDCBudget double precision,
  currentFABudget double precision,
  totalDCBudget double precision,
  totalFABudget double precision,

  spid varchar(100),
  fiscalAuthority int,
  comment text,

  container ENTITYID NOT NULL,
  createdBy USERID,
  created DATETIME,
  modifiedBy USERID,
  modified DATETIME,

  CONSTRAINT PK_grantProjects PRIMARY KEY (rowid)
);


CREATE TABLE onprc_billing.iacucFundingSources (
  rowid int identity(1,1),
  protocol varchar(200),
  grantNumber varchar(200),
  projectNumber varchar(200),

  startdate datetime,
  enddate datetime,

  container ENTITYID NOT NULL,
  createdBy USERID,
  created DATETIME,
  modifiedBy USERID,
  modified DATETIME,

  CONSTRAINT PK_iacucFundingSources PRIMARY KEY (rowid)
);

alter table onprc_billing.leaseFeeDefinition drop column project;

ALTER Table onprc_billing.invoicedItems DROP COLUMN flag;

ALTER Table onprc_billing.invoicedItems ADD credit bit;
ALTER Table onprc_billing.invoicedItems ADD lastName varchar(100);
ALTER Table onprc_billing.invoicedItems ADD firstName varchar(100);
ALTER Table onprc_billing.invoicedItems ADD project int;
ALTER Table onprc_billing.invoicedItems ADD invoiceDate datetime;
ALTER Table onprc_billing.invoicedItems ADD invoiceNumber int;
ALTER Table onprc_billing.invoicedItems ADD transactionType varchar(10);
ALTER Table onprc_billing.invoicedItems ADD department varchar(100);
ALTER Table onprc_billing.invoicedItems ADD mailcode varchar(20);
ALTER Table onprc_billing.invoicedItems ADD contactPhone varchar(30);
ALTER Table onprc_billing.invoicedItems ADD faid int;
ALTER Table onprc_billing.invoicedItems ADD cageId int;
ALTER Table onprc_billing.invoicedItems ADD objectId entityid;

ALTER Table onprc_billing.invoiceRuns ADD runDate datetime;

ALTER Table onprc_billing.invoiceRuns ADD billingPeriodStart datetime;
ALTER Table onprc_billing.invoiceRuns ADD billingPeriodEnd datetime;

ALTER Table onprc_billing.chargeableItems ADD itemCode varchar(100);
ALTER Table onprc_billing.chargeableItems ADD departmentCode varchar(100);
ALTER Table onprc_billing.invoicedItems ADD itemCode varchar(100);

ALTER Table onprc_billing.procedureFeeDefinition DROP COLUMN chargeType;
GO
ALTER Table onprc_billing.procedureFeeDefinition ADD billedby varchar(100);

ALTER Table onprc_billing.invoiceRuns ADD objectid entityid;

ALTER Table onprc_billing.procedureFeeDefinition DROP COLUMN billedby;
ALTER Table onprc_billing.procedureFeeDefinition ADD chargetype varchar(100);

ALTER TABLE onprc_billing.invoiceRuns ALTER COLUMN objectid ENTITYID NOT NULL;
GO
EXEC core.fn_dropifexists 'invoiceRuns', 'onprc_billing', 'CONSTRAINT', 'pk_invoiceRuns';

ALTER TABLE onprc_billing.invoiceRuns ADD CONSTRAINT pk_invoiceRuns PRIMARY KEY (objectid);

ALTER TABLE onprc_billing.invoicedItems ADD creditAccountId int;
ALTER TABLE onprc_billing.invoicedItems ADD invoiceId entityid;

CREATE TABLE onprc_billing.labworkFeeDefinition (
  rowid int identity(1,1),
  servicename varchar(200),
  chargeType int,
  chargeId int,

  active bit default 1,
  objectid ENTITYID,
  createdBy int,
  created datetime,
  modifiedBy int,
  modified datetime,

  CONSTRAINT PK_labworkFeeDefinition PRIMARY KEY (rowId)
);

ALTER TABLE onprc_billing.invoicedItems ADD servicecenter varchar(200);

ALTER TABLE onprc_billing.labworkFeeDefinition DROP COLUMN chargeType;
GO
ALTER TABLE onprc_billing.labworkFeeDefinition ADD chargeType varchar(100);

ALTER TABLE onprc_billing.invoicedItems ADD transactionNumber int;

ALTER TABLE onprc_billing.miscCharges ADD chargeType int;
ALTER TABLE onprc_billing.miscCharges ADD billingDate datetime;
ALTER TABLE onprc_billing.miscCharges ADD invoiceId entityid;
ALTER TABLE onprc_billing.miscCharges ADD description varchar(4000);
ALTER TABLE onprc_billing.miscCharges DROP COLUMN descrption;

ALTER TABLE onprc_billing.invoicedItems DROP COLUMN transactionNumber;
GO
ALTER TABLE onprc_billing.invoicedItems ADD transactionNumber varchar(100);

ALTER TABLE onprc_billing.miscCharges ADD objectid entityid NOT NULL;

GO
EXEC core.fn_dropifexists 'miscCharges', 'onprc_billing', 'CONSTRAINT', 'pk_miscCharges';

ALTER TABLE onprc_billing.miscCharges ADD CONSTRAINT pk_miscCharges PRIMARY KEY (objectid);

ALTER TABLE onprc_billing.miscCharges DROP COLUMN rowid;

ALTER TABLE onprc_billing.invoiceRuns DROP COLUMN runBy;
ALTER TABLE onprc_billing.invoiceRuns DROP COLUMN date;

ALTER TABLE onprc_billing.invoiceRuns ADD invoiceNumber varchar(200);

ALTER TABLE onprc_billing.miscCharges ADD invoicedItemId entityid;
ALTER TABLE onprc_billing.miscCharges DROP COLUMN description;

ALTER TABLE onprc_billing.invoicedItems ADD investigatorId int;

ALTER TABLE onprc_billing.miscCharges ADD item varchar(500);

CREATE TABLE onprc_billing.dataAccess (
  rowId int identity(1,1) NOT NULL,
  userid int,
  investigatorId int,
  project int,
  allData bit,

  container entityid NOT NULL,
  createdBy int,
  created datetime,
  modifiedBy int,
  modified datetime,

  CONSTRAINT PK_dataAccess PRIMARY KEY (rowId)
);

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

ALTER TABLE onprc_billing.grants ADD rowid int identity(1,1);
ALTER TABLE onprc_billing.grants ADD container entityid;

ALTER TABLE onprc_billing.grants DROP PK_grants;
GO
ALTER TABLE onprc_billing.grants ADD CONSTRAINT PK_grants PRIMARY KEY (rowid);
ALTER TABLE onprc_billing.grants ADD CONSTRAINT UNIQUE_grants UNIQUE (container, grantNumber);

ALTER TABLE onprc_billing.grants DROP COLUMN totalDCBudget;
ALTER TABLE onprc_billing.grants DROP COLUMN totalFABudget;

ALTER TABLE onprc_billing.grants ADD investigatorName varchar(200);
ALTER TABLE onprc_billing.grantProjects ADD investigatorName varchar(200);

ALTER TABLE onprc_billing.invoiceRuns ADD status varchar(200);

ALTER TABLE onprc_billing.miscCharges DROP COLUMN chargeType;
GO
ALTER TABLE onprc_billing.miscCharges ADD chargeType varchar(200);
ALTER TABLE onprc_billing.miscCharges ADD sourceInvoicedItem entityid;

ALTER TABLE onprc_billing.miscCharges ADD creditaccount varchar(100);

ALTER TABLE onprc_billing.grantProjects DROP COLUMN alias;
ALTER TABLE onprc_billing.grantProjects DROP COLUMN aliasEnabled;

CREATE TABLE onprc_billing.aliases (
  rowid int identity(1,1),
  alias varchar(200),
  aliasEnabled Varchar(100),

  projectNumber varchar(200),
  grantNumber varchar(200),
  agencyAwardNumber varchar(200),
  investigatorId int,
  investigatorName varchar(200),
  fiscalAuthority int,

  container ENTITYID NOT NULL,
  createdBy USERID,
  created datetime,
  modifiedBy USERID,
  modified datetime,

  CONSTRAINT PK_aliases PRIMARY KEY (rowid)
);

ALTER TABLE onprc_billing.miscCharges ADD debitedaccount varchar(200);
EXEC sp_rename 'onprc_billing.miscCharges.creditaccount', 'creditedaccount', 'COLUMN';

ALTER TABLE onprc_billing.miscCharges ADD qcstate int;

ALTER TABLE onprc_billing.perDiemFeeDefinition ADD tier varchar(100);

ALTER TABLE onprc_billing.aliases ADD fiscalAuthorityName varchar(200);

ALTER TABLE onprc_billing.chargeableItems ADD allowsCustomUnitCost bit DEFAULT 0;
GO
UPDATE onprc_billing.chargeableItems SET allowsCustomUnitCost = 0;

ALTER TABLE onprc_billing.aliases ADD category varchar(100);

ALTER TABLE onprc_billing.miscCharges ADD parentid entityid;

ALTER TABLE onprc_billing.perDiemFeeDefinition DROP COLUMN releaseCondition;
ALTER TABLE onprc_billing.perDiemFeeDefinition DROP COLUMN startDate;

CREATE TABLE onprc_billing.slaPerDiemFeeDefinition (
  rowid int IDENTITY(1,1) NOT NULL,
  chargeid int,
  cagetype varchar(100),
  cagesize varchar(100),
  species varchar(100),
  active bit,
  objectid ENTITYID,
  createdby int,
  created datetime,
  modifiedby int,
  modified datetime,

  CONSTRAINT PK_slaPerDiemFeeDefinition PRIMARY KEY (rowid)
);

ALTER TABLE onprc_billing.invoicedItems ADD chargetype varchar(100);

ALTER TABLE onprc_billing.invoicedItems ADD sourcerecord2 varchar(100);
ALTER TABLE onprc_billing.invoicedItems ADD issueId int;
ALTER TABLE onprc_billing.miscCharges ADD issueId int;

ALTER TABLE onprc_billing.chargeRateExemptions ADD remark varchar(4000);
ALTER TABLE onprc_billing.chargeRateExemptions ADD subsidy double precision;

CREATE TABLE onprc_billing.projectFARates (
  rowid int identity(1,1),
  project int,
  fa double precision,
  remark varchar(4000),
  startdate datetime,
  enddate datetime,

  container entityid,
  createdby int,
  created datetime,
  modifiedby int,
  modified datetime
);

ALTER TABLE onprc_billing.chargeRateExemptions DROP COLUMN subsidy;
ALTER TABLE onprc_billing.chargeRates ADD subsidy double precision;

DROP TABLE onprc_billing.projectFARates;
ALTER TABLE onprc_billing.aliases ADD faRate double precision;
ALTER TABLE onprc_billing.aliases ADD faSchedule varchar(200);

ALTER TABLE onprc_billing.aliases ADD budgetStartDate datetime;
ALTER TABLE onprc_billing.aliases ADD budgetEndDate datetime;

CREATE INDEX IDX_aliases ON onprc_billing.aliases (container, alias);

ALTER TABLE onprc_billing.invoicedItems DROP CONSTRAINT PK_billedItems;
GO
ALTER TABLE onprc_billing.invoicedItems ALTER COLUMN objectid ENTITYID NOT NULL;
GO
ALTER TABLE onprc_billing.invoicedItems ADD CONSTRAINT PK_invoicedItems PRIMARY KEY (objectid);

CREATE TABLE onprc_billing.chargeableItemCategories (
  category varchar(100),

  CONSTRAINT PK_chargeableItemCategories PRIMARY KEY (category)
);
GO
INSERT INTO onprc_billing.chargeableItemCategories (category) VALUES ('Animal Per Diem');
INSERT INTO onprc_billing.chargeableItemCategories (category) VALUES ('Clinical Lab Test');
INSERT INTO onprc_billing.chargeableItemCategories (category) VALUES ('Clinical Procedure');
INSERT INTO onprc_billing.chargeableItemCategories (category) VALUES ('Lease Fees');
INSERT INTO onprc_billing.chargeableItemCategories (category) VALUES ('Lease Setup Fees');
INSERT INTO onprc_billing.chargeableItemCategories (category) VALUES ('Misc. Fees');
INSERT INTO onprc_billing.chargeableItemCategories (category) VALUES ('Small Animal Per Diem');
INSERT INTO onprc_billing.chargeableItemCategories (category) VALUES ('Surgery');
INSERT INTO onprc_billing.chargeableItemCategories (category) VALUES ('Time Mated Breeders');

CREATE TABLE onprc_billing.aliasCategories (
  category varchar(100),

  CONSTRAINT PK_aliasCategories PRIMARY KEY (category)
);
GO
INSERT INTO onprc_billing.aliasCategories (category) VALUES ('OGA');
INSERT INTO onprc_billing.aliasCategories (category) VALUES ('Other');
INSERT INTO onprc_billing.aliasCategories (category) VALUES ('GL');

ALTER TABLE onprc_billing.creditAccount ADD tempaccount varchar(100);
GO
UPDATE onprc_billing.creditAccount SET tempaccount = cast(account as varchar(100));
ALTER TABLE onprc_billing.creditAccount DROP COLUMN account;
GO
ALTER TABLE onprc_billing.creditAccount ADD account varchar(100);
GO
UPDATE onprc_billing.creditAccount SET account = tempaccount;
ALTER TABLE onprc_billing.creditAccount DROP COLUMN tempaccount;

ALTER TABLE onprc_billing.aliases ADD projectTitle varchar(1000);
ALTER TABLE onprc_billing.aliases ADD projectDescription varchar(1000);
ALTER TABLE onprc_billing.aliases ADD projectStatus varchar(200);

CREATE TABLE onprc_billing.bloodDrawFeeDefinition (
    rowid int identity(1,1),
    chargeType int,
    chargeId int,

    active bit default 1,
    objectid ENTITYID,
    createdBy int,
    created datetime,
    modifiedBy int,
    modified datetime,

    CONSTRAINT PK_bloodDrawFeeDefinition PRIMARY KEY (rowId)
);

ALTER TABLE onprc_billing.bloodDrawFeeDefinition DROP COLUMN chargetype;
GO
ALTER TABLE onprc_billing.bloodDrawFeeDefinition ADD chargetype varchar(100);
ALTER TABLE onprc_billing.bloodDrawFeeDefinition ADD creditalias varchar(100);

ALTER TABLE onprc_billing.miscCharges DROP COLUMN account;
ALTER TABLE onprc_billing.miscCharges DROP COLUMN totalcost;

ALTER TABLE onprc_billing.aliases ADD aliasType VARCHAR(100);

DELETE FROM onprc_billing.aliasCategories WHERE category = 'Non-Syncing';
INSERT INTO onprc_billing.aliasCategories (category) VALUES ('Non-Syncing');

CREATE TABLE onprc_billing.aliasTypes (
    aliasType varchar(500) not null,
    removeSubsidy bit,
    canRaiseFA bit,

    createdBy integer,
    created datetime,
    modifiedBy integer,
    modified datetime,

    CONSTRAINT PK_aliasTypes PRIMARY KEY (aliasType)
);

CREATE TABLE onprc_billing.projectMultipliers (
    rowid int identity(1,1) not null,
    project integer,
    multiplier double precision,

    startdate datetime,
    enddate datetime,
    comment varchar(4000),

    container entityid,
    createdBy integer,
    created datetime,
    modifiedBy integer,
    modified datetime,

    CONSTRAINT PK_projectMultipliers PRIMARY KEY (rowid)
);

ALTER TABLE onprc_billing.chargeableItems ADD canRaiseFA bit;

ALTER TABLE onprc_billing.miscCharges ADD formSort integer;

CREATE TABLE onprc_billing.miscChargesType (
  category varchar(100) not null,

  CONSTRAINT PK_miscChargesType PRIMARY KEY (category)
);
GO
INSERT INTO onprc_billing.miscChargesType (category) VALUES ('Adjustment');
INSERT INTO onprc_billing.miscChargesType (category) VALUES ('Reversal');

ALTER TABLE onprc_billing.miscCharges ADD chargeCategory VARCHAR(100);
GO
UPDATE onprc_billing.miscCharges SET chargeCategory = chargetype;
UPDATE onprc_billing.miscCharges SET chargetype = null;

EXEC sp_rename 'onprc_billing.invoicedItems.chargetype', 'chargeCategory', 'COLUMN';

DROP TABLE onprc_billing.bloodDrawFeeDefinition;
DROP TABLE onprc_billing.clinicalFeeDefinition;

ALTER TABLE onprc_billing.perDiemFeeDefinition ADD canChargeInfants bit default 0;
ALTER TABLE onprc_billing.procedureFeeDefinition ADD assistingStaff VARCHAR(100);

CREATE TABLE onprc_billing.medicationFeeDefinition (
    rowid int identity(1,1),
    route varchar(100),
    chargeId int,

    active bit default 1,
    objectid ENTITYID,
    createdBy int,
    created datetime,
    modifiedBy int,
    modified datetime,

    CONSTRAINT PK_medicationFeeDefinition PRIMARY KEY (rowId)
);

CREATE TABLE onprc_billing.chargeUnits (
    chargetype varchar(100) NOT NULL,
    shownInBlood bit default 0,
    shownInLabwork bit default 0,
    shownInMedications bit default 0,
    shownInProcedures bit default 0,
    
    active bit default 1,
    container entityid,
    createdBy int,
    created datetime,
    modifiedBy int,
    modified datetime,

    CONSTRAINT PK_chargeUnits PRIMARY KEY (chargetype)
);

CREATE TABLE onprc_billing.chargeUnitAccounts (
    rowid int identity(1,1),
    chargetype varchar(100),
    account varchar(100),
    startdate datetime,
    enddate datetime,
    
    container entityid,
    createdBy int,
    created datetime,
    modifiedBy int,
    modified datetime,

    CONSTRAINT PK_chargeUnitAccounts PRIMARY KEY (rowid)
);

ALTER TABLE onprc_billing.chargeableItems ADD allowBlankId bit;
GO
UPDATE onprc_billing.chargeableItems SET allowBlankId = 0;

ALTER TABLE onprc_billing.projectMultipliers ADD account varchar(100);
GO
UPDATE onprc_billing.projectMultipliers SET account = (
  SELECT max(account) FROM onprc_billing.projectAccountHistory a
  WHERE a.project = projectMultipliers.project
   AND a.startdate <= CURRENT_TIMESTAMP
   AND a.enddate >= CURRENT_TIMESTAMP
);
GO
ALTER TABLE onprc_billing.projectMultipliers DROP COLUMN project;

ALTER TABLE onprc_billing.chargeUnits ADD servicecenter varchar(100);

ALTER TABLE onprc_billing.leaseFeeDefinition ADD chargeunit varchar(100);

CREATE INDEX IDX_projectAccountHistory_project_enddate ON onprc_billing.projectAccountHistory (project, enddate);

ALTER TABLE onprc_billing.medicationFeeDefinition ADD code VARCHAR(100);

--Updated 1/21/2016
--gjones
--added start and end dates to selected Finance datasets
--reset the tables


ALTER TABLE onprc_billing.procedureFeeDefinition ADD startDate DATETIME;
ALTER TABLE onprc_billing.procedureFeeDefinition ADD endDate DATETIME;

ALTER TABLE onprc_billing.labWorkFeeDefinition ADD startDate DATETIME;
ALTER TABLE onprc_billing.labWorkFeeDefinition ADD endDate DATETIME;


ALTER TABLE onprc_billing.slaPerDiemFeeDefinition ADD startDate DATETIME;
ALTER TABLE onprc_billing.slaPerDiemFeeDefinition ADD endDate DATETIME;

ALTER TABLE onprc_billing.leaseFeeDefinition ADD startDate DATETIME;
ALTER TABLE onprc_billing.leaseFeeDefinition ADD endDate DATETIME;
ALTER TABLE onprc_billing.chargeableItems ADD startDate DATETIME;
ALTER TABLE onprc_billing.chargeableItems ADD endDate DATETIME;


ALTER TABLE onprc_billing.perDiemFeeDefinition ADD startDate DATETIME;
ALTER TABLE onprc_billing.perDiemFeeDefinition ADD endDate DATETIME;

ALTER TABLE onprc_billing.medicationFeeDefinition ADD startDate DATETIME;
ALTER TABLE onprc_billing.medicationFeeDefinition ADD endDate DATETIME;
