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

/* 12.xxx SQL scripts */

-- Contents of onprc_billing-12.373-12.374.sql to onprc_billing-17.501-17.502.sql from onprc19.1Prod

--cREATED 8/25/2016
--gjones
--NEW Data set to control Inflation factor for Rates for ONPRC
--
CREATE TABLE onprc_billing.AnnualInflationRate (
                                                   billingYear varchar(10) not null,
                                                   inflationRate decimal,
                                                   startDate datetime,
                                                   endDate datetime,

                                                   createdBy integer,
                                                   created datetime,
                                                   modifiedBy integer,
                                                   modified datetime,


);

EXEC sp_rename 'onprc_billing.AnnualInflationRate', 'AnnualRateChange';

-- Created: 4-26-2017  R.Blasa

CREATE TABLE onprc_billing.MergeChargtypeUpdates (
                                                     rowid int IDENTITY(1,1) NOT NULL,
                                                     ProjectName varchar(50) not null,
                                                     Protocol varchar(100) not null,
                                                     ChargeType varchar(50) not null,
                                                     objectid ENTITYID,
                                                     startDate datetime,
                                                     endDate datetime

                                                         CONSTRAINT PK_MergeType PRIMARY KEY(rowid)
);

-- Adds table Annual Rate Change to Billing
-- Note: Unnecessary due to onprc_billing.AnnualRateChange existing in the DB
-- from when it was renamed in the 12.378-12.379 script


-- SET ANSI_NULLS ON
-- GO
--
-- SET QUOTED_IDENTIFIER ON
-- GO
-- DROP TABLE onprc_billing.AnnualRateChange;
-- CREATE TABLE onprc_billing.AnnualRateChange
-- (
-- 	[billingYear] [varchar](10) NOT NULL,
-- 	[inflationRate] [decimal](18, 0) NULL,
-- 	[startDate] [datetime] NULL,
-- 	[endDate] [datetime] NULL,
-- 	[createdBy] [int] NULL,
-- 	[created] [datetime] NULL,
-- 	[modifiedBy] [int] NULL,
-- 	[modified] [datetime] NULL
-- ) ON [PRIMARY]
-- GO

-- Adds table Annual Rate Change to Billing
-- add primary key and identity key
ALTER TABLE onprc_billing.AnnualRateChange Add RowID Int IDENTITY (1,1)not null;
ALTER TABLE onprc_billing.AnnualRateChange Add CONSTRAINT PK_AnnualRateChange_RowID PRIMARY KEY CLUSTERED (RowID);

-- Adds change inflation rate to 3 position decimal
-- add primary key and identity key
alter table [onprc_billing].[AnnualRateChange]
ALTER COLUMN InflationRate Numeric(18,4)
GO
/****** Object:  StoredProcedure [onprc_billing].[AnnualRateChangeProcess]    Script Date: 5/4/2018 10:50:22 AM ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

--DROP Procedure [onprc_billing].[AnnualRateChange]
--Go

CREATE Procedure [onprc_billing].[AnnualRateChangeProcess]

AS

BEGIN
DECLARE


@Year1     float,
                   @Year2     float,
                    @Year3     float,
                   @Year4     float,
                   @Year5     float,
                   @Year6     float,
                   @Year7     float,
                   @Year8     float,
                   @Year9     float,
                   @Aprate1   float,
                   @Aprate2   float,
                   @Aprate3   float,
                   @Aprate4   float,
                   @Aprate5   float,
                   @Aprate6   float,
                   @Aprate7   float,
                    @Aprate8   float,
                   @Aprate9   float,

                   @UnitCost    float,
                   @nSearchkey   int,
                   @TempSearchkey Int,
                   @ChargeId    SmallInt,
				   @CurrentBillingYear SmallInt,
				   @Billingyear  as Smallint








                     ---- Reset Temp tables

Delete Rpt_ChargesProjection




----- INitialize variables

Set @nSearchkey = 0
Set @TempSearchkey = 0
Set @Aprate1 = 0
Set @Aprate2 = 0
Set @Aprate3 = 0
Set @Aprate4 = 0
Set @Aprate5 = 0
Set @Aprate6 = 0
Set @Aprate7 = 0
Set @Aprate8 = 0
Set @Aprate9 = 0
SET @CurrentBillingYear = (Select DATEDIFF(Year,'5/1/1959',GetDate()))
SET @Billingyear = @CurrentBillingYear + 1



---- Begin Processing Data

select Top 1  @nSearchkey = rowid from onprc_billing.chargeRates
where endDate >= GETDATE()
order by rowid



--Billing Year Constant



Select @Aprate1 =  InflationRate from onprc_billing.AnnualRateChange

Where Billingyear = @BillingYear

Select @Aprate2 =  InflationRate from onprc_billing.AnnualRateChange

Where Billingyear = @BillingYear + 1

Select @Aprate3 =  InflationRate from onprc_billing.AnnualRateChange

Where Billingyear = @BillingYear + 2

    If exists (Select  InflationRate from onprc_billing.AnnualRateChange

                    Where Billingyear = @BillingYear + 3)
Begin

Select @Aprate4 =  InflationRate from onprc_billing.AnnualRateChange

Where Billingyear = @BillingYear + 3
End



    If exists (Select InflationRate from onprc_billing.AnnualRateChange

                    Where Billingyear = @BillingYear + 4)
Begin

Select @Aprate5 = InflationRate from onprc_billing.AnnualRateChange

Where Billingyear = @BillingYear + 4
End

    If exists (Select  InflationRate from onprc_billing.AnnualRateChange

                    Where Billingyear = @BillingYear + 5)
Begin

Select @Aprate6 =  InflationRate from onprc_billing.AnnualRateChange

Where Billingyear = @BillingYear + 5

End

    If exists (Select  InflationRate from onprc_billing.AnnualRateChange

                    Where Billingyear = @BillingYear + 6)
Begin

Select @Aprate7 =  InflationRate from onprc_billing.AnnualRateChange
Where Billingyear = @BillingYear + 6

End

    If exists (Select  InflationRate from onprc_billing.AnnualRateChange

                    Where Billingyear = @BillingYear + 7)
Begin

Select @Aprate8 =  InflationRate from onprc_billing.AnnualRateChange

Where Billingyear = @BillingYear + 7

End


    If exists (Select  InflationRate from onprc_billing.AnnualRateChange

                    Where Billingyear = @BillingYear + 8)
Begin

Select @Aprate9 =  InflationRate from onprc_billing.AnnualRateChange

Where Billingyear = @BillingYear + 8
End



    While @TempSearchKey < @nSearchkey
Begin

Set @Year1 = 0.0
Set @Year2 = 0.0
Set @Year3 = 0.0
Set @Year4 = 0.0
Set @Year5 = 0.0
Set @Year6 = 0.0
Set @Year7 = 0.0
Set @Year8 = 0.0
Set @Year9 = 0.0
Set @UnitCost = 0.0
Set @ChargeId = 0

    If exists(select *  from onprc_billing.chargeRates
    where endDate >= GETDATE()
    And rowid = @nSearchkey)
BEgin

select Top 1 @UnitCost = unitcost, @ChargeId = chargeid from onprc_billing.chargeRates
where endDate >= GETDATE()
  and rowid = @nSearchkey
order by rowid



set @Year1 = @Aprate1  * @UnitCost
Set @year2 = @year1 * @Aprate2
Set @Year3 = @year2 * @Aprate3
Set @Year4 = @year3 * @Aprate4
Set @Year5 = @year4 * @Aprate5
Set @Year6 = @year5 * @Aprate6
Set @Year7 = @year6 * @Aprate7
Set @Year8 = @year7 * @Aprate8
Set @Year9 = @year8 * @Aprate9



Insert into Rpt_ChargesProjection
values(
          @ChargeId,   ------- ChargeId
          @UnitCost,      ---- starting unit cost for the project year
          @Year1,        ----- !st Rate computation
          @Year2,        ----- !st Rate computation
          @Year3,        ----- !st Rate computation
          @Year4,        ----- !st Rate computation
          @Year5,        ----- !st Rate computation
          @Year6,        ----- !st Rate computation
          @Year7,        ----- !st Rate computation
          @Year8,        ----- !st Rate computation
          --         @Year9,        ----- !st Rate computation,
          @Aprate1,      ------ inflation rate year 57
          @Aprate2,      ------ inflation rate year 58
          @Aprate3,      ------ inflation rate year 59
          @Aprate4,      ------ inflation rate year 60
          @Aprate5,      ------ inflation rate year 61
          @Aprate6,      ------ inflation rate year 62
          @Aprate7,      ------ inflation rate year 63
          @Aprate8,      ------ inflation rate year 64
          @Aprate9,      ------ inflation rate year 65
          @nSearchkey,    ---- RowID
          getdate()       ---- run date

      )

End ---(if)


Set @TempSearchKey = @nSearchkey


select Top 1  @nSearchkey = rowid from onprc_billing.chargeRates
where endDate >= GETDATE()
  And rowid > @nSearchkey
order by rowid




End ----(While)



---Now display the results of the computation
Select chargeid as [ChargeID],
       unitcost as [UnitCost],
       Year1,
       Year2,
       Year3,
       Year4,
       Year5,
       Year6,
       Year7,
       Year8,
       --          year9,
       Rowid as [Row ID],
                            posteddate  as [PostedDate]


from  Rpt_ChargesProjection

Order by  chargeid

END

GO

/* 20.xxx SQL scripts */

-- Adds change inflation rate to 3 position decimal
-- add primary key and identity key
--If the field exists in the current build we drop the column and recreate
EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'COMMENTS';
GO
ALTER TABLE onprc_billing.aliases ADD [COMMENTS] VarChar(255) Null;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'dateDisabled';
GO
ALTER TABLE onprc_billing.aliases ADD [dateDisabled] DATETIME Null;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'PPQNumber';
GO
ALTER TABLE onprc_billing.aliases ADD [PPQNumber] VARCHAR(25) NUll;

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'PPQDate';
GO
ALTER TABLE onprc_billing.aliases ADD [PPQDate] DATETIME Null;

EXEC core.fn_dropifexists 'ogaSynch','onprc_billing','TABLE';
GO

CREATE TABLE [onprc_billing].[ogasynch](
	[lastIndexed] [datetime] NULL,
	[modifiedBy] [int] NULL,
	[container] [dbo].[ENTITYID] NOT NULL,
	[modified] [datetime] NULL,
	[created] [datetime] NULL,
	[entityId] [dbo].[ENTITYID] NOT NULL,
	[createdBy] [int] NULL,
	[ADFM EMP NUM] [int] NULL,
	[ADFM FULL NAME] [nvarchar](4000) NULL,
	[ADFM LAST NAME] [nvarchar](4000) NULL,
	[ADFM FIRST NAME] [nvarchar](4000) NULL,
	[PI EMP NUM] [int] NULL,
	[PI FULL NAME] [nvarchar](4000) NULL,
	[PI LAST NAME] [nvarchar](4000) NULL,
	[PI FIRST NAME] [nvarchar](4000) NULL,
	[PDFM EMP NUM] [int] NULL,
	[PDFM FULL NAME] [nvarchar](4000) NULL,
	[PDFM LAST NAME] [nvarchar](4000) NULL,
	[PDFM FIRST NAME] [nvarchar](4000) NULL,
	[AGENCY AWARD NUMBER] [nvarchar](4000) NULL,
	[OGA AWARD NUMBER] [nvarchar](4000) NULL,
	[OGA AWARD TYPE] [nvarchar](4000) NULL,
	[OGA PROJECT NUMBER] [nvarchar](4000) NULL,
	[ALIAS] [int] NULL,
	[ALIAS ENABLED FLAG] [bit] NULL,
	[ALIAS ENABLED FLAG_MVIndicator] [nvarchar](50) NULL,
	[PROJECT DESCRIPTION] [nvarchar](4000) NULL,
	[APPLICATION TYPE] [int] NULL,
	[ACTIVITY TYPE] [nvarchar](4000) NULL,
	[AWARD NUMBER] [nvarchar](4000) NULL,
	[AWARD SUFFIX] [nvarchar](4000) NULL,
	[ORG] [nvarchar](4000) NULL,
	[CURRENT BUDGET START DATE] [datetime] NULL,
	[CURRENT BUDGET END DATE] [datetime] NULL,
	[PROJECT TITLE] [nvarchar](4000) NULL,
	[PPQ CODE] [nvarchar](4000) NULL,
	[PPQ DATE] [datetime] NULL,
	[IACUC NUMBER] [nvarchar](4000) NULL,
	[AWARD STATUS] [nvarchar](4000) NULL,
	[PROJECT STATUS] [nvarchar](4000) NULL,
	[AWARD ID] [int] NULL,
	[PROJECT ID] [int] NULL,
	[BURDEN SCHEDULE] [nvarchar](4000) NULL,
	[BURDEN RATE] [float] NULL,
	[faRate] [float] NULL,
	[Key] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO

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

-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters
-- command (Ctrl-Shift-M) to fill in the parameter
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
-- =============================================
-- Author:		Jonesga@phsu.edu
-- Create date: 2020/4/11
-- Description:	Process to clean the onprc_billing.aliases dataset to only pertient
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'AliasCleanup202004')
    DROP PROCEDURE ALIASCleanup202004
GO
CREATE PROCEDURE onprc_billing.AliasCleanup202004

AS
BEGIN
    --Handles active non OGA Aliases
    Update a
    Set a.projectStatus = 'Active',a.comments = 'In Use - Non ONPRC Alias', a.category = 'OHSU GL'
--Se[onprc_billing].[OGA_RemoveRecords]ect a.Alias,p.account -- update the category to
    from onprc_billing.aliases a join onprc_billing.projectAccountHistory p on p.account = a.alias
    where p.enddate > = GetDate() and a.alias Not Like '9%'

-- updates the alias dataset setting end date and comment for disabled aliases
    Update a
    Set dateDisabled = '4/1/2020', Comments = 'Alias Disabled'
    from onprc_billing.aliases a
    where aliasEnabled = 'N'

    Update a1
    set a1.projectStatus = 'Non Active GL', a1.aliasEnabled = 'n', a1.datedisabled = GetDate(), a1.comments = 'GL Alias Not Active entered Previously'

    from onprc_billing.aliases a1 left outer join onprc_billing.projectAccountHistory p on p.account = a1.alias
    where a1.alias not like '9%' and (a1.comments != 'In Use - Non ONPRC Alias' or a1.comments is null)

    Update a2
    Set a2.dateDisabled = GetDate(), comments = 'Expired Alias', aliasEnabled = 'n'
--select a1.alias,a1.budgetEndDate
    from onprc_billing.aliases a2
    where a2.budgetEndDate <=GetDate()

    Update a4
    set dateDisabled = GetDate(), comments = 'Grant Closed', projectStatus = 'Grant Closed', aliasEnabled = 'N'
--Select a4.alias,s.[PROJECT STATUS],a4.projectStatus
    from onprc_billing.aliases a4 left Outer join onprc_billing.ogaSynch s on Cast(a4.alias as varchar(50)) = Cast(s.[alias] as VarChar(50))
    where a4.dateDisabled is null and a4.projectstatus in ('Archived','Closed','IM PURGEd')
--Remove Records not associated with ONPRC
    DELETE FROM onprc_billing.aliases
    where alias in (Select a.alias
                    from onprc_billing.aliases a left outer join onprc_billing.projectAccountHistory p on a.alias = p.account
                    where p.account is  null and a.dateDisabled is not null)
    --Update the existing data to add PPQ, ORG PPQ Date to Existing Aliases
--Update a10
--Set A10. =  s.ORG, a10.PPQNumber = s.[PPQ CODE], a10.PPQDate = s.[PPQ DATE]
--from onprc_billing.aliases a10 left Outer join onprc_billing.ogaSynch s on Cast(a10.alias as varchar(50)) = Cast(s.[alias] as VarChar(50))
--where a10.Org is null
END
GO

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

/****** Object:  StoredProcedure [onprc_billing].[OGA_RemoveRecords]
  cREATED 2020-05-18
    cREATED BY JONESGA
  Purpose:  Resets the Alias Dataset for Insert from OGA, Keeping GL Accounts

  Script Date: 5/18/2020 10:33:15 AM ******/
EXEC core.fn_dropifexists 'OGA_RemoveRecords', 'onprc_billing', 'PROCEDURE'
GO

CREATE PROCEDURE [onprc_billing].[OGA_RemoveRecords]
    AS
    BEGIN

        Delete from onprc_billing.aliases
        where category != 'OHSU GL'



    END

GO

/****** Object:  StoredProcedure [onprc_billing].[oga_InsertRecords]    Script Date: 5/18/2020 10:35:50 AM ******/
EXEC core.fn_dropifexists 'oga_InsertRecords', 'onprc_billing', 'PROCEDURE'
GO

CREATE PROCEDURE [onprc_billing].[oga_InsertRecords]

    AS
    BEGIN

        INSERT INTO [onprc_billing].[aliases]
        ([alias]
        ,[aliasEnabled]
        ,[projectNumber]
        ,[grantNumber]
        ,[agencyAwardNumber]
        ,[investigatorId]
        ,[investigatorName]
        ,[fiscalAuthority]
        ,[container]
        ,[createdBy]
        ,[created]
        ,[category]
        ,[faRate]
        ,[faSchedule]
        ,[budgetStartDate]
        ,[budgetEndDate]
        ,[projectTitle]
        ,[projectDescription]
        ,[projectStatus]
        ,[aliasType]
        ,[COMMENTS]
        ,[PPQNumber]
        ,[PPQDate]
        ,[AwardStatus]
        ,[AwardID]
        ,[ApplicationType]
        ,[ProjectID]
        ,[ActivityType]
        ,[AwardNumber]
        ,[AwardSuffix]
        ,[ADFMEmpNum]
        ,[ADFMFullName]
        ,[Org]
        )
        SELECT
            [Alias]
             ,[ALIAS ENABLED FLAG_MVIndicator]
             ,[OGA PROJECT NUMBER]
             ,[OGA AWARD NUMBER]
             ,[AGENCY AWARD NUMBER]
             ,[PI EMP NUM]
             ,[PI FULL NAME]
             ,[PDFM EMP NUM]
             ,'0F8BB08E-E4BF-102F-B89B-5107380A5B61'
             ,1003
             ,GetDate()
             ,'OGA'
             ,[BURDEN RATE]
             ,[BURDEN SCHEDULE]
             ,[CURRENT BUDGET START DATE]
             ,[CURRENT BUDGET END DATE]
             ,[PROJECT TITLE]
             ,[PROJECT DESCRIPTION]
             ,[PROJECT STATUS]
             ,[ACTIVITY TYPE]
             ,'ENTERED BY ISE'
             ,[PPQ CODE]
             ,[PPQ DATE]
             ,[AWARD STATUS]
             ,[AWARD ID]
             ,[APPLICATION TYPE]
             ,[PROJECT ID]
             ,[OGA AWARD TYPE]
             ,[AWARD NUMBER]
             ,[AWARD SUFFIX]
             ,[ADFM EMP NUM]
             ,[ADFM FULL NAME]
             ,[ORG]
        From [onprc_billing].[ogasynch]
    END

GO

/****** Object:  StoredProcedure [onprc_billing].[oga_InsertRecords]    Script Date: 5/21/2020 5:43:28 AM ******/
/*****Update 2020-05-21 to handle Investigator and FA Ids in Prime*******/

ALTER PROCEDURE [onprc_billing].[oga_InsertRecords]

    AS
    BEGIN

        INSERT INTO [onprc_billing].[aliases]
        ([alias]
        ,[aliasEnabled]
        ,[projectNumber]
        ,[grantNumber]
        ,[agencyAwardNumber]
        ,[investigatorId]
        ,[investigatorName]
        ,[fiscalAuthority]
        ,[container]
        ,[createdBy]
        ,[created]
        ,[category]
        ,[faRate]
        ,[faSchedule]
        ,[budgetStartDate]
        ,[budgetEndDate]
        ,[projectTitle]
        ,[projectDescription]
        ,[projectStatus]
        ,[aliasType]
        ,[COMMENTS]
        ,[PPQNumber]
        ,[PPQDate]
        ,[AwardStatus]
        ,[AwardID]
        ,[ApplicationType]
        ,[ProjectID]
        ,[ActivityType]
        ,[AwardNumber]
        ,[AwardSuffix]
        ,[ADFMEmpNum]
        ,[ADFMFullName]
        ,[Org]
        )
        SELECT
            [Alias]
             ,Case
                  when [ALIAS ENABLED FLAG] =  0 then 'n'
                  when [ALIAS ENABLED FLAG] = 1 then 'y'
            End  as AliasEndabled

             --,[ALIAS ENABLED FLAG]
             ,[OGA PROJECT NUMBER]
             ,[OGA AWARD NUMBER]
             ,[AGENCY AWARD NUMBER]
             ,Case
                  When (Select rowID from [onprc_ehr].[investigators] where [PI EMP NUM] = employeeID and datedisabled is null) is not null
                      Then (Select rowID from [onprc_ehr].[investigators] where [PI EMP NUM] = employeeID and datedisabled is null)
                  Else Null
            End as InvestigatorID
             -- ,[PI EMP NUM]
             -- ,(Select rowID from [onprc_ehr].[investigators] where [PI EMP NUM] = employeeID and datedisabled is null) as PILastName
             -- [PI EMP NUM]
             ,[PI FULL NAME]
             ,(Select rowid from [onprc_billing].[fiscalAuthorities] where [PDFM EMP NUM] = employeeID and active = 1) as fiscalAuthority
             ,'0F8BB08E-E4BF-102F-B89B-5107380A5B61'
             ,1003
             ,GetDate()
             ,'OGA'
             ,[BURDEN RATE]
             ,[BURDEN SCHEDULE]
             ,[CURRENT BUDGET START DATE]
             ,[CURRENT BUDGET END DATE]
             ,[PROJECT TITLE]
             ,[PROJECT DESCRIPTION]
             ,[PROJECT STATUS]
             ,[ACTIVITY TYPE]
             ,'ENTERED BY ISE'
             ,[PPQ CODE]
             ,[PPQ DATE]
             ,[AWARD STATUS]
             ,[AWARD ID]
             ,[APPLICATION TYPE]
             ,[PROJECT ID]
             ,[OGA AWARD TYPE]
             ,[AWARD NUMBER]
             ,[AWARD SUFFIX]
             ,[ADFM EMP NUM]
             ,[ADFM FULL NAME]
             ,[ORG]
        From [onprc_billing].[ogasynch]

        Update [Labkey].[onprc_billing].[aliases]
         Set aliasEnabled = 'n'
         --where AliasEnabled is null
         --Select * from [Labkey].[onprc_billing].[aliases]
         where ((budgetEndDate < GetDate() or budgetEndDate is null) or category != 'OHSU GL')

    END

GO

CREATE FUNCTION [onprc_ehr].[RateCalc]
    (
    @alias varchar(20),
    @chargeId float,
    @project float,
    @startDate date,
    @baseSubsidyVal float
    )

    RETURNS float
    AS
BEGIN
Declare @unitCostVal float,
			   @projectExemption float,
			   @projectMultipler float,
			   @unitCost float,
			   @NonOGAAlias varchar(20),
			   @blankAliasType varchar(20),
			   @baseSubsidy float,
			   @subsidy float,
               @faRate float,
               @removeSubsidy smallInt,
               @aliasRaiseFA smallInt,
               @chargeRaiseFA smallInt


	--initiate Variables
	--determine if there is a project level exemption
	--the base subsidy is defined as a gloabl variable in the Labkey Java Code in onprc_ehr.java and if a change in the base rate is requested, the data needs to be updated in each position
Set @baseSubsidyVal = .47
Set @basesubsidy = .47
Set @unitCost = 1000
Set @subsidy = @baseSubsidyVal
Set @projectExemption = (Select cr.unitcost From onprc_billing.chargeRateExemptions cr
    Where cr.chargeId = @chargeId
    and cr.project = @project
    and cr.startDate < @startDate
    and ((@startDate <= cr.endDate) or (cr.enddate is null)))

--determine if there is a project level multiplier	--	onprc_billing.projectMultipler
--verified the query
Set @projectMultipler = (Select pm.multiplier From onprc_billing.projectMultipliers pm
    Where pm.account = @alias
    and pm.startdate <= @startDate
    and ((pm.enddate >= @startDate) or (pm.enddate is Null)))


--determine if the alias is a non oga rate --onprc_billing.aliases --category column
--verified query
Set @NonOGAAlias = (Select a.category From onprc_billing.aliases a
    Where a.alias = @alias
    and (a.budgetStartDate < @startDate and a.budgetEndDate > @startDate))

----determine if Alias Type is Blank
----verified query
Set @blankAliasType = (Select a.aliasType From onprc_billing.aliases a
    Where a.alias = @alias
    and (a.budgetStartDate < @startDate and a.budgetEndDate > @startDate))

----determine if remove subsidy if true
----verified query
Set @removeSubsidy = (Select t.removeSubsidy From onprc_billing.aliases a join onprc_billing.aliasTypes t on a.aliasType = t.aliasType
    Where a.alias = @alias
    and (a.budgetStartDate < @startDate and a.budgetEndDate > @startDate))

----determine if raise F&A is True for Charge Rate --Need to set date parameters on most of these
----Need to lock down date range
Set @chargeRaiseFA = (Select c.canRaiseFA From onprc_billing.chargeableItems c join onprc_billing.chargeRates cr on c.rowId = cr.chargeId
    Where cr.chargeId = @chargeId
    and (cr.StartDate < @startDate and cr.EndDate > @startDate))

----determine if rate F&A is true for alias
Set @aliasRaiseFA = (Select t.canRaiseFA From onprc_billing.aliases a join onprc_billing.aliasTypes t on a.aliasType = t.aliasType
    Where a.alias = @alias
    and (a.budgetStartDate < @startDate and a.budgetEndDate > @startDate))

----get FA Rate for Alias
Set @faRate = (Select a.faRate From onprc_billing.aliases a
    Where a.alias = @alias
    and (a.budgetStartDate < @startDate and a.budgetEndDate > @startDate))

--determine unit cost
--if it retunrs null there is no charge rate
Set @unitCost = (Select r.unitcost From onprc_billing.chargeRates r
    Where r.chargeID = @chargeId
    and r.startDate <= @startDate
    and ((r.enddate >= @startDate) or r.enddate Is Null))

--determine Unit Cost
Select @unitCostVal =

       Case
           --returns unit cost when there is an exemption at the project level
           When @projectExemption is not null then @projectExemption
           --return value for a charge that has a pm multiplier
           When @projectMultipler is not null then @projectMultipler * @unitCost
           ------ --where there is no unit cost listed return null
           When @unitCost is null then null
           --where the alias type is not OGA charge NIH Rate
           When @NonOGAAlias is not null and @NonOGAAlias != 'OGA' then @unitCost
           ------when alias type is not known then return null
           When @blankAliasType is null then null

           When (@removeSubsidy = 1 AND (@aliasRaiseFA = 1 AND @chargeRaiseFA = 1))
               THEN ((@unitCost / (1 - COALESCE(@subsidy, 0))) * (CASE WHEN (@faRate IS NOT NULL AND @faRate < @baseSubsidy) THEN (1 + @baseSubsidy / (1 + @faRate)) ELSE 1 END))

           When (@removeSubsidy = 1 AND @aliasRaiseFA = 0)
               THEN (@unitCost / (1 - COALESCE(@subsidy, 0)))


           When (@removeSubsidy = 0 AND (@aliasRaiseFA = 1 AND @chargeRaiseFA = 1))
               Then (@unitCost * (CASE WHEN (@faRate IS NOT NULL AND @faRate = 0) THEN  (1 + @Subsidy / (1 + @faRate)) ELSE 1 END))

           When (@removeSubsidy = 0 AND (@aliasRaiseFA = 1 AND @chargeRaiseFA = 1))
               Then (@unitCost * (CASE WHEN (@faRate IS NOT NULL AND @faRate < @Subsidy) THEN (1 + @Subsidy / (1 + @faRate)) ELSE 1 END))

           Else @unitCost
           END

           --return @unitCost
           return @unitCostVal--@projectExemption

End

GO

/****** Object:  StoredProcedure [onprc_billing].[OGA_RemoveRecords]    Script Date: 10/15/2020 9:30:00 AM ******/

EXEC core.fn_dropifexists 'ClearOGASync', 'onprc_billing', 'PROCEDURE'
GO

CREATE PROCEDURE [onprc_billing].[ClearOGASync]
AS
BEGIN

Delete from onprc_billing.ogasynch

END

GO

/****** Object:  StoredProcedure [onprc_billing].[oga_InsertRecords]
  Script Date: 5/18/2020 10:35:50 AM
Update 2020-11-25 jonesga to change source of fa rate from burden rate to cast value
  ******/
EXEC core.fn_dropifexists 'oga_InsertRecords', 'onprc_billing', 'PROCEDURE'
GO

CREATE PROCEDURE [onprc_billing].[oga_InsertRecords]

    AS
    BEGIN

        INSERT INTO [onprc_billing].[aliases]
        ([alias]
        ,[aliasEnabled]
        ,[projectNumber]
        ,[grantNumber]
        ,[agencyAwardNumber]
        ,[investigatorId]
        ,[investigatorName]
        ,[fiscalAuthority]
        ,[container]
        ,[createdBy]
        ,[created]
        ,[category]
        ,[faRate]
        ,[faSchedule]
        ,[budgetStartDate]
        ,[budgetEndDate]
        ,[projectTitle]
        ,[projectDescription]
        ,[projectStatus]
        ,[aliasType]
        ,[COMMENTS]
        ,[PPQNumber]
        ,[PPQDate]
        ,[AwardStatus]
        ,[AwardID]
        ,[ApplicationType]
        ,[ProjectID]
        ,[ActivityType]
        ,[AwardNumber]
        ,[AwardSuffix]
        ,[ADFMEmpNum]
        ,[ADFMFullName]
        ,[Org]
        )
        SELECT
            [Alias]
             ,[ALIAS ENABLED FLAG_MVIndicator]
             ,[OGA PROJECT NUMBER]
             ,[OGA AWARD NUMBER]
             ,[AGENCY AWARD NUMBER]
             ,[PI EMP NUM]
             ,[PI FULL NAME]
             ,[PDFM EMP NUM]
             ,'0F8BB08E-E4BF-102F-B89B-5107380A5B61'
             ,1003
             ,GetDate()
             ,'OGA'
             ,[farate]
             ,[BURDEN SCHEDULE]
             ,[CURRENT BUDGET START DATE]
             ,[CURRENT BUDGET END DATE]
             ,[PROJECT TITLE]
             ,[PROJECT DESCRIPTION]
             ,[PROJECT STATUS]
             ,[ACTIVITY TYPE]
             ,'ENTERED BY ISE'
             ,[PPQ CODE]
             ,[PPQ DATE]
             ,[AWARD STATUS]
             ,[AWARD ID]
             ,[APPLICATION TYPE]
             ,[PROJECT ID]
             ,[OGA AWARD TYPE]
             ,[AWARD NUMBER]
             ,[AWARD SUFFIX]
             ,[ADFM EMP NUM]
             ,[ADFM FULL NAME]
             ,[ORG]
        From [onprc_billing].[ogasynch]
    END

GO

/****** Object:  StoredProcedure [onprc_billing].[oga_InsertRecords]
  Script Date: 5/18/2020 10:35:50 AM
Update 2020-11-25 jonesga to change source of fa rate from burden rate to cast value
  ******/
EXEC core.fn_dropifexists 'oga_InsertRecords', 'onprc_billing', 'PROCEDURE'
GO

CREATE PROCEDURE [onprc_billing].[oga_InsertRecords]


    AS
BEGIN

INSERT INTO [onprc_billing].[aliases]
([alias]
,[aliasEnabled]
,[projectNumber]
,[grantNumber]
,[agencyAwardNumber]
,[investigatorId]
,[investigatorName]
,[fiscalAuthority]
,[container]
,[createdBy]
,[created]
,[category]
,[faRate]
,[faSchedule]
,[budgetStartDate]
,[budgetEndDate]
,[projectTitle]
,[projectDescription]
,[projectStatus]
,[aliasType]
,[COMMENTS]
,[PPQNumber]
,[PPQDate]
,[AwardStatus]
,[AwardID]
,[ApplicationType]
,[ProjectID]
,[ActivityType]
,[AwardNumber]
,[AwardSuffix]
,[ADFMEmpNum]
,[ADFMFullName]
,[Org]
)
SELECT
    [Alias],
    Case
        when [ALIAS ENABLED FLAG] =  1 then 'y'
        when [ALIAS ENABLED FLAG] =  0 then 'n'
        End as AliasEnabled
    --  ,[ALIAS ENABLED FLAG]
        ,[OGA PROJECT NUMBER]
             ,[OGA AWARD NUMBER]
             ,[AGENCY AWARD NUMBER]
             ,[PI EMP NUM]
             ,[PI FULL NAME]
             ,[PDFM EMP NUM]
             ,'0F8BB08E-E4BF-102F-B89B-5107380A5B61'
             ,1003
             ,GetDate()
             ,'OGA'
             ,[farate]
             ,[BURDEN SCHEDULE]
             ,[CURRENT BUDGET START DATE]
             ,[CURRENT BUDGET END DATE]
             ,[PROJECT TITLE]
             ,[PROJECT DESCRIPTION]
             ,[PROJECT STATUS]
             ,[ACTIVITY TYPE]
             ,'ENTERED BY ISE'
             ,[PPQ CODE]
             ,[PPQ DATE]
             ,[AWARD STATUS]
             ,[AWARD ID]
             ,[APPLICATION TYPE]
             ,[PROJECT ID]
             ,[OGA AWARD TYPE]
             ,[AWARD NUMBER]
             ,[AWARD SUFFIX]
             ,[ADFM EMP NUM]
             ,[ADFM FULL NAME]
             ,[ORG]
        From [onprc_billing].[ogasynch]
END
GO

/****** Object:  StoredProcedure [onprc_billing].[oga_InsertRecords]    Script Date: 12/2/2020 12:18:09 PM ******/
EXEC core.fn_dropifexists 'oga_InsertRecords', 'onprc_billing', 'PROCEDURE'
GO

CREATE PROCEDURE [onprc_billing].[oga_InsertRecords]


AS
BEGIN

INSERT INTO [onprc_billing].[aliases]
([alias]
,[aliasEnabled]
,[projectNumber]
,[grantNumber]
,[agencyAwardNumber]
,[investigatorId]
,[investigatorName]
,[fiscalAuthority]
,[container]
,[createdBy]
,[created]
,[category]
,[faRate]
,[faSchedule]
,[budgetStartDate]
,[budgetEndDate]
,[projectTitle]
,[projectDescription]
,[projectStatus]
,[aliasType]
,[COMMENTS]
,[PPQNumber]
,[PPQDate]
,[AwardStatus]
,[AwardID]
,[ApplicationType]
,[ProjectID]
,[ActivityType]
,[AwardNumber]
,[AwardSuffix]
,[ADFMEmpNum]
,[ADFMFullName]
,[Org]
)
SELECT
    [Alias],
    Case
        when [ALIAS ENABLED FLAG] =  1 then 'y'
        when [ALIAS ENABLED FLAG] =  0 then 'n'
        End as AliasEnabled

        ,[OGA PROJECT NUMBER]
             ,[OGA AWARD NUMBER]
             ,[AGENCY AWARD NUMBER]
             ,i.rowId
			--End as [PI EMP NUM]
			 ,[PI FULL NAME]
			 ,f.rowid
			 --,[PDFM EMP NUM]
            ,'0F8BB08E-E4BF-102F-B89B-5107380A5B61'
             ,1003
             ,GetDate()
             ,'OGA'
             ,[farate]
             ,[BURDEN SCHEDULE]
             ,[CURRENT BUDGET START DATE]
             ,[CURRENT BUDGET END DATE]
             ,[PROJECT TITLE]
             ,[PROJECT DESCRIPTION]
             ,[PROJECT STATUS]
             ,[ACTIVITY TYPE]
             ,'ENTERED BY ISE'
             ,[PPQ CODE]
             ,[PPQ DATE]
             ,[AWARD STATUS]
             ,[AWARD ID]
             ,[APPLICATION TYPE]
             ,[PROJECT ID]
             ,[OGA AWARD TYPE]
             ,[AWARD NUMBER]
             ,[AWARD SUFFIX]
             ,[ADFM EMP NUM]
             ,[ADFM FULL NAME]
             ,[ORG]

        From [onprc_billing].[ogasynch] o
		left outer join [onprc_ehr].investigators i on o.[PI EMP NUM] = i.employeeid
		left outer join onprc_billing.fiscalAuthorities f on f.employeeId = o.[PDFM EMP NUM]
END
GO

EXEC core.fn_dropifexists 'oga_InsertRecords', 'onprc_billing', 'PROCEDURE'
GO

CREATE PROCEDURE [onprc_billing].[oga_InsertRecords] AS
BEGIN

INSERT INTO [onprc_billing].[aliases]
([alias]
,[aliasEnabled]
,[projectNumber]
,[grantNumber]
,[agencyAwardNumber]
,[investigatorId]
,[investigatorName]
,[fiscalAuthority]
,[container]
,[createdBy]
,[created]
,[category]
,[faRate]
,[faSchedule]
,[budgetStartDate]
,[budgetEndDate]
,[projectTitle]
,[projectDescription]
,[projectStatus]
,[aliasType]
,[COMMENTS]
,[PPQNumber]
,[PPQDate]
,[AwardStatus]
,[AwardID]
,[ApplicationType]
,[ProjectID]
,[ActivityType]
,[AwardNumber]
,[AwardSuffix]
,[ADFMEmpNum]
,[ADFMFullName]
,[Org]
)
SELECT
    [Alias],
    Case
        when [ALIAS ENABLED FLAG] =  1 then 'y'
        when [ALIAS ENABLED FLAG] =  0 then 'n'
        End as AliasEnabled

        ,[OGA PROJECT NUMBER]
             ,[OGA AWARD NUMBER]
             ,[AGENCY AWARD NUMBER]
             ,i.rowId
			--End as [PI EMP NUM]
			 ,[PI FULL NAME]
			 ,f.rowid
			 --,[PDFM EMP NUM]
            ,'0F8BB08E-E4BF-102F-B89B-5107380A5B61'
             ,1003
             ,GetDate()
             ,'OGA'
             ,[farate]
             ,[BURDEN SCHEDULE]
             ,[CURRENT BUDGET START DATE]
             ,[CURRENT BUDGET END DATE]
             ,[PROJECT TITLE]
             ,[PROJECT DESCRIPTION]
             ,[PROJECT STATUS]
             ,[OGA AWARD TYPE]
             ,'ENTERED BY ISE'
             ,[PPQ CODE]
             ,[PPQ DATE]
             ,[AWARD STATUS]
             ,[AWARD ID]
             ,[APPLICATION TYPE]
             ,[PROJECT ID]
             ,[OGA AWARD TYPE]
             ,[AWARD NUMBER]
             ,[AWARD SUFFIX]
             ,[ADFM EMP NUM]
             ,[ADFM FULL NAME]
             ,[ORG]

        From [onprc_billing].[ogasynch] o
		left outer join [onprc_ehr].investigators i on o.[PI EMP NUM] = i.employeeid
		left outer join onprc_billing.fiscalAuthorities f on f.employeeId = o.[PDFM EMP NUM]
END
GO

EXEC core.fn_dropifexists 'oga_InsertRecords', 'onprc_billing', 'PROCEDURE'
GO

CREATE PROCEDURE [onprc_billing].[oga_InsertRecords] AS
BEGIN

INSERT INTO [onprc_billing].[aliases]
([alias]
,[aliasEnabled]
,[projectNumber]
,[grantNumber]
,[agencyAwardNumber]
,[investigatorId]
,[investigatorName]
,[fiscalAuthority]
,[container]
,[createdBy]
,[created]
,[category]
,[faRate]
,[faSchedule]
,[budgetStartDate]
,[budgetEndDate]
,[projectTitle]
,[projectDescription]
,[projectStatus]
,[aliasType]
,[COMMENTS]
,[PPQNumber]
,[PPQDate]
,[AwardStatus]
,[AwardID]
,[ApplicationType]
,[ProjectID]
,[ActivityType]
,[AwardNumber]
,[AwardSuffix]
,[ADFMEmpNum]
,[ADFMFullName]
,[Org]
)
SELECT
    [Alias],
    Case
        when [ALIAS ENABLED FLAG] =  1 then 'y'
        when [ALIAS ENABLED FLAG] =  0 then 'n'
        End as AliasEnabled

        ,[OGA PROJECT NUMBER]
             ,[OGA AWARD NUMBER]
             ,[AGENCY AWARD NUMBER]
             ,i.rowId
			--End as [PI EMP NUM]
			 ,[PI FULL NAME]
			 ,f.rowid
			 --,[PDFM EMP NUM]
            ,'0F8BB08E-E4BF-102F-B89B-5107380A5B61'
             ,1003
             ,GetDate()
             ,'OGA'
             ,[farate]
             ,[BURDEN SCHEDULE]
             ,[CURRENT BUDGET START DATE]
             ,[CURRENT BUDGET END DATE]
             ,[PROJECT TITLE]
             ,[PROJECT DESCRIPTION]
             ,[PROJECT STATUS]
             ,[OGA AWARD TYPE]
             ,'ENTERED BY ISE'
             ,[PPQ CODE]
             ,[PPQ DATE]
             ,[AWARD STATUS]
             ,[AWARD ID]
             ,[APPLICATION TYPE]
             ,[PROJECT ID]
             ,[OGA AWARD TYPE]
             ,[AWARD NUMBER]
             ,[AWARD SUFFIX]
             ,[ADFM EMP NUM]
             ,[ADFM FULL NAME]
             ,[ORG]

        From [onprc_billing].[ogasynch] o
		left outer join [onprc_ehr].investigators i on o.[PI EMP NUM] = i.employeeid and i.datedisabled is Null
		left outer join onprc_billing.fiscalAuthorities f on f.employeeId = o.[PDFM EMP NUM] and f.active = 'true';

END
GO

EXEC core.fn_dropifexists 'oga_InsertRecords', 'onprc_billing', 'PROCEDURE'
GO

CREATE PROCEDURE [onprc_billing].[oga_InsertRecords] AS
BEGIN

INSERT INTO [onprc_billing].[aliases]
([alias]
,[aliasEnabled]
,[projectNumber]
,[grantNumber]
,[agencyAwardNumber]
,[investigatorId]
,[investigatorName]
,[fiscalAuthority]
,[container]
,[createdBy]
,[created]
,[category]
,[faRate]
,[faSchedule]
,[budgetStartDate]
,[budgetEndDate]
,[projectTitle]
,[projectDescription]
,[projectStatus]
,[aliasType]
,[COMMENTS]
,[PPQNumber]
,[PPQDate]
,[AwardStatus]
,[AwardID]
,[ApplicationType]
,[ProjectID]
,[ActivityType]
,[AwardNumber]
,[AwardSuffix]
,[ADFMEmpNum]
,[ADFMFullName]
,[Org]
)
SELECT
    [Alias],
    Case
        when [ALIAS ENABLED FLAG] =  1 then 'y'
        when [ALIAS ENABLED FLAG] =  0 then 'n'
        End as AliasEnabled

        ,[OGA PROJECT NUMBER]
             ,[OGA AWARD NUMBER]
             ,[AGENCY AWARD NUMBER]
             ,i.rowId
			--End as [PI EMP NUM]
			 ,[PI FULL NAME]
			 ,f.rowid
			 --,[PDFM EMP NUM]
            ,'0F8BB08E-E4BF-102F-B89B-5107380A5B61'
             ,1003
             ,GetDate()
             ,'OGA'
             ,[farate]
             ,[BURDEN SCHEDULE]
             ,[CURRENT BUDGET START DATE]
             ,[CURRENT BUDGET END DATE]
             ,[PROJECT TITLE]
             ,[PROJECT DESCRIPTION]
             ,[PROJECT STATUS]
             ,[OGA AWARD TYPE]
             ,'ENTERED BY ISE'
             ,[PPQ CODE]
             ,[PPQ DATE]
             ,[AWARD STATUS]
             ,[AWARD ID]
             ,[APPLICATION TYPE]
             ,[PROJECT ID]
             ,[OGA AWARD TYPE]
             ,[AWARD NUMBER]
             ,[AWARD SUFFIX]
             ,[ADFM EMP NUM]
             ,[ADFM FULL NAME]
             ,[ORG]

        From [onprc_billing].[ogasynch] o
		left outer join [onprc_ehr].investigators i on o.[PI EMP NUM] = i.employeeid and i.datedisabled is Null
		left outer join onprc_billing.fiscalAuthorities f on f.employeeId = o.[PDFM EMP NUM] and f.active = 'true';

END
GO

/* 22.xxx SQL scripts */

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'Originating Agency Award Number';
GO
ALTER TABLE onprc_billing.aliases ADD [OriginatingAgencyAwardNum] VarChar(255) Null;
GO
ALTER TABLE onprc_billing.ogaSynch ADD [ORIGINATING_AGENCY_AWARD_NUM] VarChar(255) Null;

--20220406 update of SP for insert
EXEC core.fn_dropifexists 'oga_InsertRecords', 'onprc_billing', 'PROCEDURE'
GO

CREATE PROCEDURE [onprc_billing].[oga_InsertRecords] AS
BEGIN

INSERT INTO [onprc_billing].[aliases]
([alias]
,[aliasEnabled]
,[projectNumber]
,[grantNumber]
,[agencyAwardNumber]
,[investigatorId]
,[investigatorName]
,[fiscalAuthority]
,[container]
,[createdBy]
,[created]
,[category]
,[faRate]
,[faSchedule]
,[budgetStartDate]
,[budgetEndDate]
,[projectTitle]
,[projectDescription]
,[projectStatus]
,[aliasType]
,[COMMENTS]
,[PPQNumber]
,[PPQDate]
,[AwardStatus]
,[AwardID]
,[ApplicationType]
,[ProjectID]
,[ActivityType]
,[AwardNumber]
,[AwardSuffix]
,[ADFMEmpNum]
,[ADFMFullName]
,[Org]
,[OriginatingAgencyAwardNum]
)
SELECT
    [Alias],
    Case
        when [ALIAS ENABLED FLAG] =  1 then 'y'
        when [ALIAS ENABLED FLAG] =  0 then 'n'
        End as AliasEnabled

        ,[OGA PROJECT NUMBER]
             ,[OGA AWARD NUMBER]
             ,[AGENCY AWARD NUMBER]
             ,i.rowId
			--End as [PI EMP NUM]
			 ,[PI FULL NAME]
			 ,f.rowid
			 --,[PDFM EMP NUM]
            ,'0F8BB08E-E4BF-102F-B89B-5107380A5B61'
             ,1003
             ,GetDate()
             ,'OGA'
             ,[farate]
             ,[BURDEN SCHEDULE]
             ,[CURRENT BUDGET START DATE]
             ,[CURRENT BUDGET END DATE]
             ,[PROJECT TITLE]
             ,[PROJECT DESCRIPTION]
             ,[PROJECT STATUS]
             ,[OGA AWARD TYPE]
             ,'ENTERED BY ISE'
             ,[PPQ CODE]
             ,[PPQ DATE]
             ,[AWARD STATUS]
             ,[AWARD ID]
             ,[APPLICATION TYPE]
             ,[PROJECT ID]
             ,[OGA AWARD TYPE]
             ,[AWARD NUMBER]
             ,[AWARD SUFFIX]
             ,[ADFM EMP NUM]
             ,[ADFM FULL NAME]
             ,[ORG]
             ,[ORIGINATING_AGENCY_AWARD_NUM]
        From [onprc_billing].[ogasynch] o
		left outer join [onprc_ehr].investigators i on o.[PI EMP NUM] = i.employeeid and i.datedisabled is Null
		left outer join onprc_billing.fiscalAuthorities f on f.employeeId = o.[PDFM EMP NUM] and f.active = 'true';

END
GO

EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'OriginatingAgencyAwardNum';
GO
EXEC core.fn_dropifexists 'ogaSynch', 'onprc_billing', 'COLUMN', 'ORIGINATING_AGENCY_AWARD_NUM';
GO
ALTER TABLE onprc_billing.aliases ADD [OriginatingAgencyAwardNum] VarChar(255) Null;
GO
ALTER TABLE onprc_billing.ogaSynch ADD [ORIGINATING_AGENCY_AWARD_NUM] VarChar(255) Null;

/* 23.xxx SQL scripts */

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'UpdateClinPathEndDate')
DROP PROCEDURE UpdateClinPathEndDate
    GO
CREATE PROCEDURE onprc_billing.UpdateClinPathEndDate

    AS
BEGIN
    --Updates end Date for ClinPath when complete but no dateUpdate [Labkey_uat].[studyDataset].[c6d199_clinpathruns]
    --update todya 8/16/2023
Update [studyDataset].[c6d199_clinpathruns]
set datefinalized =  date
where dateFinalized is null and date > '5/1/2023' and qcstate = 18





END
GO

/*Corrected to remove sql script not related to this module.*/
EXEC core.fn_dropifexists 'annualinflationrate','onprc_billing','table',Null