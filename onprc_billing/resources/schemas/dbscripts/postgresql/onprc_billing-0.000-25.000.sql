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

--this table contains one row each time a billing run is performed, which gleans items to be charged from a variety of sources
--and snapshots them into invoicedItems
CREATE TABLE onprc_billing.invoiceRuns (
    rowId SERIAL NOT NULL,
    date TIMESTAMP,
    dataSources varchar(1000),
    runBy userid,
    comment varchar(4000),

    container ENTITYID NOT NULL,
    createdBy USERID,
    created TIMESTAMP,
    modifiedBy USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_invoiceRuns PRIMARY KEY (rowId)
);

--this table contains a snapshot of items actually invoiced, which will draw from many places in the animal record
CREATE TABLE onprc_billing.invoicedItems (
    rowId SERIAL NOT NULL,
    id varchar(100),
    date TIMESTAMP,
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
    created TIMESTAMP,
    modifiedBy USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_billedItems PRIMARY KEY (rowId)
);


--this table contains a list of all potential items that can be charged.  it maps between the integer ID
--and a descriptive name.  it does not contain any fee information
CREATE TABLE onprc_billing.chargableItems (
    rowId SERIAL NOT NULL,
    name varchar(200),
    category varchar(200),
    comment varchar(4000),
    active boolean default true,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created TIMESTAMP,
    modifiedBy USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_chargableItems PRIMARY KEY (rowId)
);

--this table contains a list of the current changes for each item in onprc_billing.charges
--it will retain historic information, so we can accurately determine 'cost at the time'
CREATE TABLE onprc_billing.chargeRates (
    rowId SERIAL NOT NULL,
    chargeId int,
    unitcost double precision,
    unit varchar(100),
    startDate timestamp,
    endDate timestamp,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created TIMESTAMP,
    modifiedBy USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_chargeRates PRIMARY KEY (rowId)
);

--contains records of project-specific exemptions to chargeRates
CREATE TABLE onprc_billing.chargeRateExemptions (
    rowId SERIAL NOT NULL,
    project int,
    chargeId int,
    unitcost double precision,
    unit varchar(100),
    startDate timestamp,
    endDate timestamp,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created TIMESTAMP,
    modifiedBy USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_chargeRateExemptions PRIMARY KEY (rowId)
);

--maps the account to be credited for each charged item
CREATE TABLE onprc_billing.creditAccount (
    rowId SERIAL NOT NULL,
    chargeId int,
    account int,
    startDate timestamp,
    endDate timestamp,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created TIMESTAMP,
    modifiedBy USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_creditAccount PRIMARY KEY (rowId)
);

--this table contains records of misc charges that have happened that cannot otherwise be
--automatically inferred from the record
CREATE TABLE onprc_billing.miscCharges (
    rowId SERIAL NOT NULL,
    id varchar(100),
    date TIMESTAMP,
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
    created TIMESTAMP,
    modifiedBy USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_miscCharges PRIMARY KEY (rowId)
);


--this table details how to calculate lease fees, and produces a list of charges over a billing period
--no fee info is contained
CREATE TABLE onprc_billing.leaseFeeDefinition (
    rowId SERIAL NOT NULL,
    minAge int,
    maxAge int,

    assignCondition int,
    releaseCondition int,
    chargeId int,

    active boolean default true,
    objectid ENTITYID,
    createdBy int,
    created TIMESTAMP,
    modifiedBy int,
    modified TIMESTAMP,

    CONSTRAINT PK_leaseFeeDefinition PRIMARY KEY (rowId)
);

--this table details how to calculate lease fees, and produces a list of charges over a billing period
--no fee info is contained
CREATE TABLE onprc_billing.perDiemFeeDefinition (
    rowId SERIAL NOT NULL,
    chargeId int,
    housingType int,
    housingDefinition int,

    startdate timestamp,
    releaseCondition int,

    active boolean default true,
    objectid ENTITYID,
    createdBy int,
    created TIMESTAMP,
    modifiedBy int,
    modified TIMESTAMP,

    CONSTRAINT PK_perDiemFeeDefinition PRIMARY KEY (rowId)
);

--creates list of all procedures that are billable
CREATE TABLE onprc_billing.clinicalFeeDefinition (
    rowId SERIAL NOT NULL,
    procedureId int,
    snomed varchar(100),

    active boolean default true,
    objectid ENTITYID,
    createdBy int,
    created TIMESTAMP,
    modifiedBy int,
    modified TIMESTAMP,

    CONSTRAINT PK_clinicalFeeDefinition PRIMARY KEY (rowId)
);

ALTER TABLE onprc_billing.chargeRates drop column unit;
ALTER TABLE onprc_billing.chargeRateExemptions drop column unit;

alter table onprc_billing.leaseFeeDefinition add project int;
alter table onprc_billing.chargableItems add shortName varchar(100);

CREATE TABLE onprc_billing.procedureFeeDefinition (
    rowid serial NOT NULL,
    procedureId int,
    chargeType int,
    chargeId int,

    active boolean default true,
    objectid ENTITYID,
    createdBy int,
    created timestamp,
    modifiedBy int,
    modified timestamp,

    CONSTRAINT PK_procedureFeeDefinition PRIMARY KEY (rowId)
);

CREATE TABLE onprc_billing.financialContacts (
    rowid serial NOT NULL,
    firstName varchar(100),
    lastName varchar(100),
    position varchar(100),
    address varchar(500),
    city varchar(100),
    state varchar(100),
    country varchar(100),
    zip varchar(100),
    phoneNumber varchar(100),

    active boolean default true,
    objectid ENTITYID,
    createdBy int,
    created timestamp,
    modifiedBy int,
    modified timestamp,

    CONSTRAINT PK_financialContacts PRIMARY KEY (rowId)
);

CREATE TABLE onprc_billing.grants (
    "grant" varchar(100),
    investigatorId int,
    title varchar(500),
    startDate timestamp,
    endDate timestamp,
    fiscalAuthority int,

    createdBy int,
    created timestamp,
    modifiedBy int,
    modified timestamp,

    CONSTRAINT PK_grants PRIMARY KEY ("grant")
);

CREATE TABLE onprc_billing.accounts (
    account varchar(100),
    "grant" varchar(100),
    investigator integer,
    startdate timestamp,
    enddate timestamp,
    externalid varchar(200),
    comment varchar(4000),
    fiscalAuthority int,
    tier integer,
    active boolean default true,

    objectid entityid,
    createdBy userid,
    created timestamp,
    modifiedBy userid,
    modified timestamp,

    CONSTRAINT PK_accounts PRIMARY KEY (account)
);

drop table onprc_billing.financialContacts;

CREATE TABLE onprc_billing.fiscalAuthorities (
    rowid serial NOT NULL,
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

    active boolean default true,
    objectid ENTITYID,
    createdBy int,
    created timestamp,
    modifiedBy int,
    modified timestamp,

    CONSTRAINT pk_fiscalAuthorities PRIMARY KEY (rowId)
);

CREATE TABLE onprc_billing.projectAccountHistory (
  rowid serial NOT NULL,
  project int,
  account varchar(200),
  startdate timestamp,
  enddate timestamp,
  objectid entityid,
  createdby userid,
  created timestamp,
  modifiedby userid,
  modified timestamp
);

DROP TABLE onprc_billing.chargableItems;

CREATE TABLE onprc_billing.chargeableItems (
    rowId SERIAL NOT NULL,
    name varchar(200),
    shortName varchar(100),
    category varchar(200),
    comment varchar(4000),
    active boolean default true,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created TIMESTAMP,
    modifiedBy USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_chargeableItems PRIMARY KEY (rowId)
);

ALTER TABLE onprc_billing.projectAccountHistory ADD CONSTRAINT PK_projectAccountHistory PRIMARY KEY (rowid);

DROP TABLE onprc_billing.grants;

CREATE TABLE onprc_billing.grants (
    grantNumber varchar(100),
    investigatorId int,
    title varchar(500),
    startDate timestamp,
    endDate timestamp,
    fiscalAuthority int,
    fundingAgency varchar(200),
    grantType varchar(200),

    totalDCBudget double precision,
    totalFABudget double precision,
    budgetStartDate timestamp,
    budgetEndDate timestamp,

    agencyAwardNumber varchar(200),
    comment text,

    createdBy int,
    created timestamp,
    modifiedBy int,
    modified timestamp,

    CONSTRAINT PK_grants PRIMARY KEY (grantNumber)
);

DROP TABLE onprc_billing.accounts;

CREATE TABLE onprc_billing.grantProjects (
  rowid serial NOT NULL,
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

  awardStartDate timestamp,
  awardEndDate timestamp,
  budgetStartDate timestamp,
  budgetEndDate timestamp,
  currentDCBudget double precision,
  currentFABudget double precision,
  totalDCBudget double precision,
  totalFABudget double precision,

  spid varchar(100),
  fiscalAuthority int,
  comment text,

  container ENTITYID NOT NULL,
  createdBy USERID,
  created TIMESTAMP,
  modifiedBy USERID,
  modified TIMESTAMP,

  CONSTRAINT PK_grantProjects PRIMARY KEY (rowid)
);

CREATE TABLE onprc_billing.iacucFundingSources (
  rowid serial NOT NULL,
  protocol varchar(200),
  grantNumber varchar(200),
  projectNumber varchar(200),

  startdate timestamp,
  enddate timestamp,

  container ENTITYID NOT NULL,
  createdBy USERID,
  created TIMESTAMP,
  modifiedBy USERID,
  modified TIMESTAMP,

  CONSTRAINT PK_iacucFundingSources PRIMARY KEY (rowid)
);

alter table onprc_billing.leaseFeeDefinition drop column project;

ALTER Table onprc_billing.invoicedItems DROP COLUMN flag;

ALTER Table onprc_billing.invoicedItems ADD credit boolean;
ALTER Table onprc_billing.invoicedItems ADD lastName varchar(100);
ALTER Table onprc_billing.invoicedItems ADD firstName varchar(100);
ALTER Table onprc_billing.invoicedItems ADD project int;
ALTER Table onprc_billing.invoicedItems ADD invoiceDate timestamp;
ALTER Table onprc_billing.invoicedItems ADD invoiceNumber int;
ALTER Table onprc_billing.invoicedItems ADD transactionType varchar(10);
ALTER Table onprc_billing.invoicedItems ADD department varchar(100);
ALTER Table onprc_billing.invoicedItems ADD mailcode varchar(20);
ALTER Table onprc_billing.invoicedItems ADD contactPhone varchar(30);
ALTER Table onprc_billing.invoicedItems ADD faid int;
ALTER Table onprc_billing.invoicedItems ADD cageId int;
ALTER Table onprc_billing.invoicedItems ADD objectId entityid;

ALTER Table onprc_billing.invoiceRuns ADD runDate timestamp;

ALTER Table onprc_billing.invoiceRuns ADD billingPeriodStart timestamp;
ALTER Table onprc_billing.invoiceRuns ADD billingPeriodEnd timestamp;

ALTER Table onprc_billing.chargeableItems ADD itemCode varchar(100);
ALTER Table onprc_billing.chargeableItems ADD departmentCode varchar(100);
ALTER Table onprc_billing.invoicedItems ADD itemCode varchar(100);

ALTER Table onprc_billing.procedureFeeDefinition DROP COLUMN chargeType;
ALTER Table onprc_billing.procedureFeeDefinition ADD billedby varchar(100);

ALTER Table onprc_billing.invoiceRuns ADD objectid entityid;

ALTER Table onprc_billing.procedureFeeDefinition DROP COLUMN billedby;
ALTER Table onprc_billing.procedureFeeDefinition ADD chargetype varchar(100);

ALTER TABLE onprc_billing.invoiceRuns ALTER COLUMN objectid SET NOT NULL;

ALTER TABLE onprc_billing.invoiceRuns DROP CONSTRAINT IF EXISTS pk_invoiceRuns;
ALTER TABLE onprc_billing.invoiceRuns ADD CONSTRAINT pk_invoiceRuns PRIMARY KEY (objectid);

ALTER TABLE onprc_billing.invoicedItems ADD creditAccountId int;
ALTER TABLE onprc_billing.invoicedItems ADD invoiceId entityid;

CREATE TABLE onprc_billing.labworkFeeDefinition (
  rowid serial NOT NULL,
  servicename varchar(200),
  chargeType int,
  chargeId int,

  active boolean default true,
  objectid ENTITYID,
  createdBy int,
  created timestamp,
  modifiedBy int,
  modified timestamp,

  CONSTRAINT PK_labworkFeeDefinition PRIMARY KEY (rowId)
);

ALTER TABLE onprc_billing.invoicedItems ADD servicecenter varchar(200);

ALTER TABLE onprc_billing.labworkFeeDefinition DROP COLUMN chargeType;
ALTER TABLE onprc_billing.labworkFeeDefinition ADD chargeType varchar(100);

ALTER TABLE onprc_billing.invoicedItems ADD transactionNumber int;

ALTER TABLE onprc_billing.miscCharges ADD chargeType int;
ALTER TABLE onprc_billing.miscCharges ADD billingDate timestamp;
ALTER TABLE onprc_billing.miscCharges ADD invoiceId entityid;
ALTER TABLE onprc_billing.miscCharges ADD description varchar(4000);
ALTER TABLE onprc_billing.miscCharges DROP COLUMN descrption;

ALTER TABLE onprc_billing.invoicedItems DROP COLUMN transactionNumber;
ALTER TABLE onprc_billing.invoicedItems ADD transactionNumber varchar(100);

ALTER TABLE onprc_billing.miscCharges ADD objectid entityid NOT NULL;

ALTER TABLE onprc_billing.miscCharges DROP CONSTRAINT IF EXISTS pk_miscCharges;

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
  rowId serial NOT NULL,
  userid int,
  investigatorId int,
  project int,
  allData boolean,

  container entityid NOT NULL,
  createdBy int,
  created timestamp,
  modifiedBy int,
  modified timestamp,

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

ALTER TABLE onprc_billing.grants ADD rowid serial;
ALTER TABLE onprc_billing.grants ADD container entityid;

ALTER TABLE onprc_billing.grants DROP CONSTRAINT PK_grants;
ALTER TABLE onprc_billing.grants ADD CONSTRAINT PK_grants PRIMARY KEY (rowid);
ALTER TABLE onprc_billing.grants ADD CONSTRAINT UNIQUE_grants UNIQUE (container, grantNumber);

ALTER TABLE onprc_billing.grants DROP COLUMN totalDCBudget;
ALTER TABLE onprc_billing.grants DROP COLUMN totalFABudget;

ALTER TABLE onprc_billing.grants ADD investigatorName varchar(200);
ALTER TABLE onprc_billing.grantProjects ADD investigatorName varchar(200);

ALTER TABLE onprc_billing.invoiceRuns ADD status varchar(200);

ALTER TABLE onprc_billing.miscCharges DROP COLUMN chargeType;
ALTER TABLE onprc_billing.miscCharges ADD chargeType varchar(200);
ALTER TABLE onprc_billing.miscCharges ADD sourceInvoicedItem entityid;

ALTER TABLE onprc_billing.miscCharges ADD creditaccount varchar(100);

ALTER TABLE onprc_billing.grantProjects DROP COLUMN alias;
ALTER TABLE onprc_billing.grantProjects DROP COLUMN aliasEnabled;

CREATE TABLE onprc_billing.aliases (
  rowid serial NOT NULL,
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
  created timestamp,
  modifiedBy USERID,
  modified timestamp,

  CONSTRAINT PK_aliases PRIMARY KEY (rowid)
);

ALTER TABLE onprc_billing.miscCharges ADD debitedaccount varchar(200);
ALTER TABLE onprc_billing.miscCharges RENAME COLUMN creditaccount TO creditedaccount;

ALTER TABLE onprc_billing.miscCharges ADD qcstate int;

ALTER TABLE onprc_billing.perDiemFeeDefinition ADD tier varchar(100);

ALTER TABLE onprc_billing.aliases ADD fiscalAuthorityName varchar(200);

ALTER TABLE onprc_billing.chargeableItems ADD allowsCustomUnitCost boolean DEFAULT false;
UPDATE onprc_billing.chargeableItems SET allowsCustomUnitCost = false;

ALTER TABLE onprc_billing.aliases ADD category varchar(100);

ALTER TABLE onprc_billing.miscCharges ADD parentid entityid;

ALTER TABLE onprc_billing.perDiemFeeDefinition DROP COLUMN releaseCondition;
ALTER TABLE onprc_billing.perDiemFeeDefinition DROP COLUMN startDate;

CREATE TABLE onprc_billing.slaPerDiemFeeDefinition (
  rowid serial NOT NULL,
  chargeid int,
  cagetype varchar(100),
  cagesize varchar(100),
  species varchar(100),
  active boolean,
  objectid ENTITYID,
  createdby int,
  created timestamp,
  modifiedby int,
  modified timestamp,

  CONSTRAINT PK_slaPerDiemFeeDefinition PRIMARY KEY (rowid)
);

ALTER TABLE onprc_billing.invoicedItems ADD chargetype varchar(100);

ALTER TABLE onprc_billing.invoicedItems ADD sourcerecord2 varchar(100);
ALTER TABLE onprc_billing.invoicedItems ADD issueId int;
ALTER TABLE onprc_billing.miscCharges ADD issueId int;

ALTER TABLE onprc_billing.chargeRateExemptions ADD remark varchar(4000);
ALTER TABLE onprc_billing.chargeRateExemptions ADD subsidy double precision;

CREATE TABLE onprc_billing.projectFARates (
  rowid serial NOT NULL,
  project int,
  fa double precision,
  remark varchar(4000),
  startdate timestamp,
  enddate timestamp,

  container entityid,
  createdby int,
  created timestamp,
  modifiedby int,
  modified timestamp
);

ALTER TABLE onprc_billing.chargeRateExemptions DROP COLUMN subsidy;
ALTER TABLE onprc_billing.chargeRates ADD subsidy double precision;

DROP TABLE onprc_billing.projectFARates;
ALTER TABLE onprc_billing.aliases ADD faRate double precision;
ALTER TABLE onprc_billing.aliases ADD faSchedule varchar(200);

ALTER TABLE onprc_billing.aliases ADD budgetStartDate timestamp;
ALTER TABLE onprc_billing.aliases ADD budgetEndDate timestamp;

CREATE INDEX IDX_aliases ON onprc_billing.aliases (container, alias);

ALTER TABLE onprc_billing.invoicedItems DROP CONSTRAINT PK_billedItems;
ALTER TABLE onprc_billing.invoicedItems ALTER COLUMN objectid SET NOT NULL;
ALTER TABLE onprc_billing.invoicedItems ADD CONSTRAINT PK_invoicedItems PRIMARY KEY (objectid);

CREATE TABLE onprc_billing.chargeableItemCategories (
  category varchar(100),

  CONSTRAINT PK_chargeableItemCategories PRIMARY KEY (category)
);

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

INSERT INTO onprc_billing.aliasCategories (category) VALUES ('OGA');
INSERT INTO onprc_billing.aliasCategories (category) VALUES ('Other');
INSERT INTO onprc_billing.aliasCategories (category) VALUES ('GL');

ALTER TABLE onprc_billing.creditAccount ADD tempaccount varchar(100);
UPDATE onprc_billing.creditAccount SET tempaccount = cast(account as varchar(100));
ALTER TABLE onprc_billing.creditAccount DROP COLUMN account;
ALTER TABLE onprc_billing.creditAccount ADD account varchar(100);
UPDATE onprc_billing.creditAccount SET account = tempaccount;
ALTER TABLE onprc_billing.creditAccount DROP COLUMN tempaccount;

ALTER TABLE onprc_billing.aliases ADD projectTitle varchar(1000);
ALTER TABLE onprc_billing.aliases ADD projectDescription varchar(1000);
ALTER TABLE onprc_billing.aliases ADD projectStatus varchar(200);

CREATE TABLE onprc_billing.bloodDrawFeeDefinition (
    rowid serial NOT NULL,
    chargeType int,
    chargeId int,

    active boolean default true,
    objectid ENTITYID,
    createdBy int,
    created timestamp,
    modifiedBy int,
    modified timestamp,

    CONSTRAINT PK_bloodDrawFeeDefinition PRIMARY KEY (rowId)
);

ALTER TABLE onprc_billing.bloodDrawFeeDefinition DROP COLUMN chargetype;
ALTER TABLE onprc_billing.bloodDrawFeeDefinition ADD chargetype varchar(100);
ALTER TABLE onprc_billing.bloodDrawFeeDefinition ADD creditalias varchar(100);

ALTER TABLE onprc_billing.miscCharges DROP COLUMN account;
ALTER TABLE onprc_billing.miscCharges DROP COLUMN totalcost;

ALTER TABLE onprc_billing.aliases ADD aliasType VARCHAR(100);

DELETE FROM onprc_billing.aliasCategories WHERE category = 'Non-Syncing';
INSERT INTO onprc_billing.aliasCategories (category) VALUES ('Non-Syncing');

CREATE TABLE onprc_billing.aliasTypes (
    aliasType varchar(500) not null,
    removeSubsidy boolean,
    canRaiseFA boolean,

    createdBy integer,
    created timestamp,
    modifiedBy integer,
    modified timestamp,

    CONSTRAINT PK_aliasTypes PRIMARY KEY (aliasType)
);

CREATE TABLE onprc_billing.projectMultipliers (
    rowid serial not null,
    project integer,
    multiplier double precision,

    startdate timestamp,
    enddate timestamp,
    comment varchar(4000),

    container entityid,
    createdBy integer,
    created timestamp,
    modifiedBy integer,
    modified timestamp,

    CONSTRAINT PK_projectMultipliers PRIMARY KEY (rowid)
);

ALTER TABLE onprc_billing.chargeableItems ADD canRaiseFA boolean;

ALTER TABLE onprc_billing.miscCharges ADD formSort integer;

CREATE TABLE onprc_billing.miscChargesType (
  category varchar(100) not null,

  CONSTRAINT PK_miscChargesType PRIMARY KEY (category)
);

INSERT INTO onprc_billing.miscChargesType (category) VALUES ('Adjustment');
INSERT INTO onprc_billing.miscChargesType (category) VALUES ('Reversal');

ALTER TABLE onprc_billing.miscCharges ADD chargeCategory VARCHAR(100);
UPDATE onprc_billing.miscCharges SET chargeCategory = chargetype;
UPDATE onprc_billing.miscCharges SET chargetype = null;

ALTER TABLE onprc_billing.invoicedItems RENAME COLUMN chargetype TO chargeCategory;

DROP TABLE onprc_billing.bloodDrawFeeDefinition;
DROP TABLE onprc_billing.clinicalFeeDefinition;

ALTER TABLE onprc_billing.perDiemFeeDefinition ADD canChargeInfants boolean default false;
ALTER TABLE onprc_billing.procedureFeeDefinition ADD assistingStaff VARCHAR(100);

CREATE TABLE onprc_billing.medicationFeeDefinition (
    rowid serial NOT NULL,
    route varchar(100),
    chargeId int,

    active boolean default true,
    objectid ENTITYID,
    createdBy int,
    created timestamp,
    modifiedBy int,
    modified timestamp,

    CONSTRAINT PK_medicationFeeDefinition PRIMARY KEY (rowId)
);

CREATE TABLE onprc_billing.chargeUnits (
    chargetype varchar(100) NOT NULL,
    shownInBlood boolean default false,
    shownInLabwork boolean default false,
    shownInMedications boolean default false,
    shownInProcedures boolean default false,
    
    active boolean default true,
    container entityid,
    createdBy int,
    created timestamp,
    modifiedBy int,
    modified timestamp,

    CONSTRAINT PK_chargeUnits PRIMARY KEY (chargetype)
);

CREATE TABLE onprc_billing.chargeUnitAccounts (
    rowid serial NOT NULL,
    chargetype varchar(100),
    account varchar(100),
    startdate timestamp,
    enddate timestamp,
    
    container entityid,
    createdBy int,
    created timestamp,
    modifiedBy int,
    modified timestamp,

    CONSTRAINT PK_chargeUnitAccounts PRIMARY KEY (rowid)
);

ALTER TABLE onprc_billing.chargeableItems ADD allowBlankId boolean;
UPDATE onprc_billing.chargeableItems SET allowBlankId = false;

ALTER TABLE onprc_billing.projectMultipliers ADD account varchar(100);
UPDATE onprc_billing.projectMultipliers SET account = (
  SELECT max(account) FROM onprc_billing.projectAccountHistory a
  WHERE a.project = projectMultipliers.project
   AND a.startdate <= CURRENT_TIMESTAMP
   AND a.enddate >= CURRENT_TIMESTAMP
);
ALTER TABLE onprc_billing.projectMultipliers DROP COLUMN project;

ALTER TABLE onprc_billing.chargeUnits ADD servicecenter varchar(100);

ALTER TABLE onprc_billing.leaseFeeDefinition ADD chargeunit varchar(100);

CREATE INDEX IDX_projectAccountHistory_project_enddate ON onprc_billing.projectAccountHistory (project, enddate);

ALTER TABLE onprc_billing.medicationFeeDefinition ADD code VARCHAR(100);

--Updated 1/21/2016
--gjones
--added start and end dates to selected Finance datasets
--reset the tables

ALTER TABLE onprc_billing.procedureFeeDefinition ADD startDate TIMESTAMP;
ALTER TABLE onprc_billing.procedureFeeDefinition ADD endDate TIMESTAMP;

ALTER TABLE onprc_billing.labWorkFeeDefinition ADD startDate TIMESTAMP;
ALTER TABLE onprc_billing.labWorkFeeDefinition ADD endDate TIMESTAMP;

ALTER TABLE onprc_billing.slaPerDiemFeeDefinition ADD startDate TIMESTAMP;
ALTER TABLE onprc_billing.slaPerDiemFeeDefinition ADD endDate TIMESTAMP;

ALTER TABLE onprc_billing.leaseFeeDefinition ADD startDate TIMESTAMP;
ALTER TABLE onprc_billing.leaseFeeDefinition ADD endDate TIMESTAMP;
ALTER TABLE onprc_billing.chargeableItems ADD startDate TIMESTAMP;
ALTER TABLE onprc_billing.chargeableItems ADD endDate TIMESTAMP;

ALTER TABLE onprc_billing.perDiemFeeDefinition ADD startDate TIMESTAMP;
ALTER TABLE onprc_billing.perDiemFeeDefinition ADD endDate TIMESTAMP;

ALTER TABLE onprc_billing.medicationFeeDefinition ADD startDate TIMESTAMP;
ALTER TABLE onprc_billing.medicationFeeDefinition ADD endDate TIMESTAMP;

/* 12.xxx SQL scripts */

-- Contents of onprc_billing-12.373-12.374.sql to onprc_billing-17.501-17.502.sql from onprc19.1Prod

--cREATED 8/25/2016
--gjones
--NEW Data set to control Inflation factor for Rates for ONPRC

CREATE TABLE onprc_billing.AnnualInflationRate (
    billingYear varchar(10) not null,
    inflationRate decimal,
    startDate timestamp,
    endDate timestamp,

    createdBy integer,
    created timestamp,
    modifiedBy integer,
    modified timestamp
);

ALTER TABLE onprc_billing.AnnualInflationRate RENAME TO AnnualRateChange;

-- Created: 4-26-2017  R.Blasa

CREATE TABLE onprc_billing.MergeChargtypeUpdates (
    rowid serial NOT NULL,
    ProjectName varchar(50) not null,
    Protocol varchar(100) not null,
    ChargeType varchar(50) not null,
    objectid ENTITYID,
    startDate timestamp,
    endDate timestamp,

    CONSTRAINT PK_MergeType PRIMARY KEY(rowid)
);

-- Adds table Annual Rate Change to Billing
-- add primary key and identity key
ALTER TABLE onprc_billing.AnnualRateChange Add RowID serial not null;
ALTER TABLE onprc_billing.AnnualRateChange Add CONSTRAINT PK_AnnualRateChange_RowID PRIMARY KEY (RowID);

-- Adds change inflation rate to 3 position decimal
-- add primary key and identity key
ALTER TABLE onprc_billing.AnnualRateChange ALTER COLUMN InflationRate TYPE Numeric(18,4);

-- RETAINED BUT DEAD - translated for completeness only; do not wire this up as-is.
-- 1. It reads and writes Rpt_ChargesProjection, which no script in any module creates.
-- 2. Nothing calls it. rateChangeprocess.xml invokes onprc_billing.AnnualRateChangeUpdate,
--    a routine that exists in neither dialect.
-- 3. The SQL Server original ended by returning a result set (SELECT ... FROM Rpt_ChargesProjection
--    ORDER BY chargeid). That is dropped here, since a plpgsql function cannot return a result set
--    without a refcursor or RETURNS TABLE. Reviving this would mean creating the table and
--    reinstating that result set.
-- Contrast onprc_ehr.PrimaSlideBillingReport / PrimaBlockBillingReport, which were dropped from the
-- PostgreSQL translation for the same reason. That omission is silent; this one is recorded here.
CREATE OR REPLACE FUNCTION onprc_billing.AnnualRateChangeProcess()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_Year1           double precision;
    v_Year2           double precision;
    v_Year3           double precision;
    v_Year4           double precision;
    v_Year5           double precision;
    v_Year6           double precision;
    v_Year7           double precision;
    v_Year8           double precision;
    v_Year9           double precision;
    v_Aprate1         double precision := 0;
    v_Aprate2         double precision := 0;
    v_Aprate3         double precision := 0;
    v_Aprate4         double precision := 0;
    v_Aprate5         double precision := 0;
    v_Aprate6         double precision := 0;
    v_Aprate7         double precision := 0;
    v_Aprate8         double precision := 0;
    v_Aprate9         double precision := 0;

    v_UnitCost        double precision := 0.0;
    v_nSearchkey      int := 0;
    v_TempSearchkey   int := 0;
    v_ChargeId        smallint := 0;
    v_CurrentBillingYear smallint;
    v_Billingyear     smallint;
BEGIN
    ---- Reset Temp tables
    DELETE FROM Rpt_ChargesProjection;

    v_CurrentBillingYear := (EXTRACT(YEAR FROM CURRENT_TIMESTAMP) - 1959)::smallint;
    v_Billingyear := v_CurrentBillingYear + 1;

    ---- Begin Processing Data
    SELECT rowid INTO v_nSearchkey
    FROM onprc_billing.chargeRates
    WHERE endDate >= CURRENT_TIMESTAMP
    ORDER BY rowid
    LIMIT 1;

    --Billing Year Constant
    SELECT InflationRate INTO v_Aprate1 FROM onprc_billing.AnnualRateChange WHERE Billingyear = v_BillingYear::varchar;
    SELECT InflationRate INTO v_Aprate2 FROM onprc_billing.AnnualRateChange WHERE Billingyear = (v_BillingYear + 1)::varchar;
    SELECT InflationRate INTO v_Aprate3 FROM onprc_billing.AnnualRateChange WHERE Billingyear = (v_BillingYear + 2)::varchar;

    IF EXISTS (SELECT 1 FROM onprc_billing.AnnualRateChange WHERE Billingyear = (v_BillingYear + 3)::varchar) THEN
        SELECT InflationRate INTO v_Aprate4 FROM onprc_billing.AnnualRateChange WHERE Billingyear = (v_BillingYear + 3)::varchar;
    END IF;

    IF EXISTS (SELECT 1 FROM onprc_billing.AnnualRateChange WHERE Billingyear = (v_BillingYear + 4)::varchar) THEN
        SELECT InflationRate INTO v_Aprate5 FROM onprc_billing.AnnualRateChange WHERE Billingyear = (v_BillingYear + 4)::varchar;
    END IF;

    IF EXISTS (SELECT 1 FROM onprc_billing.AnnualRateChange WHERE Billingyear = (v_BillingYear + 5)::varchar) THEN
        SELECT InflationRate INTO v_Aprate6 FROM onprc_billing.AnnualRateChange WHERE Billingyear = (v_BillingYear + 5)::varchar;
    END IF;

    IF EXISTS (SELECT 1 FROM onprc_billing.AnnualRateChange WHERE Billingyear = (v_BillingYear + 6)::varchar) THEN
        SELECT InflationRate INTO v_Aprate7 FROM onprc_billing.AnnualRateChange WHERE Billingyear = (v_BillingYear + 6)::varchar;
    END IF;

    IF EXISTS (SELECT 1 FROM onprc_billing.AnnualRateChange WHERE Billingyear = (v_BillingYear + 7)::varchar) THEN
        SELECT InflationRate INTO v_Aprate8 FROM onprc_billing.AnnualRateChange WHERE Billingyear = (v_BillingYear + 7)::varchar;
    END IF;

    IF EXISTS (SELECT 1 FROM onprc_billing.AnnualRateChange WHERE Billingyear = (v_BillingYear + 8)::varchar) THEN
        SELECT InflationRate INTO v_Aprate9 FROM onprc_billing.AnnualRateChange WHERE Billingyear = (v_BillingYear + 8)::varchar;
    END IF;

    WHILE v_TempSearchKey < v_nSearchkey LOOP
        v_Year1 := 0.0;
        v_Year2 := 0.0;
        v_Year3 := 0.0;
        v_Year4 := 0.0;
        v_Year5 := 0.0;
        v_Year6 := 0.0;
        v_Year7 := 0.0;
        v_Year8 := 0.0;
        v_Year9 := 0.0;
        v_UnitCost := 0.0;
        v_ChargeId := 0;

        IF EXISTS(SELECT 1 FROM onprc_billing.chargeRates WHERE endDate >= CURRENT_TIMESTAMP AND rowid = v_nSearchkey) THEN
            SELECT unitcost, chargeid INTO v_UnitCost, v_ChargeId
            FROM onprc_billing.chargeRates
            WHERE endDate >= CURRENT_TIMESTAMP AND rowid = v_nSearchkey
            ORDER BY rowid
            LIMIT 1;

            v_Year1 := v_Aprate1 * v_UnitCost;
            v_Year2 := v_Year1 * v_Aprate2;
            v_Year3 := v_Year2 * v_Aprate3;
            v_Year4 := v_Year3 * v_Aprate4;
            v_Year5 := v_Year4 * v_Aprate5;
            v_Year6 := v_Year5 * v_Aprate6;
            v_Year7 := v_Year6 * v_Aprate7;
            v_Year8 := v_Year7 * v_Aprate8;
            v_Year9 := v_Year8 * v_Aprate9;

            INSERT INTO Rpt_ChargesProjection
            VALUES (
                v_ChargeId,
                v_UnitCost,
                v_Year1,
                v_Year2,
                v_Year3,
                v_Year4,
                v_Year5,
                v_Year6,
                v_Year7,
                v_Year8,
                v_Aprate1,
                v_Aprate2,
                v_Aprate3,
                v_Aprate4,
                v_Aprate5,
                v_Aprate6,
                v_Aprate7,
                v_Aprate8,
                v_Aprate9,
                v_nSearchkey,
                CURRENT_TIMESTAMP
            );
        END IF;

        v_TempSearchKey := v_nSearchkey;

        SELECT rowid INTO v_nSearchkey
        FROM onprc_billing.chargeRates
        WHERE endDate >= CURRENT_TIMESTAMP AND rowid > v_nSearchkey
        ORDER BY rowid
        LIMIT 1;

        IF NOT FOUND THEN
            EXIT;
        END IF;
    END LOOP;
END;
$$;

/* 20.xxx SQL scripts */

-- Adds change inflation rate to 3 position decimal
-- add primary key and identity key
--If the field exists in the current build we drop the column and recreate
ALTER TABLE onprc_billing.aliases ADD COMMENTS VarChar(255) Null;

ALTER TABLE onprc_billing.aliases ADD dateDisabled TIMESTAMP Null;

ALTER TABLE onprc_billing.aliases ADD PPQNumber VARCHAR(25) Null;

ALTER TABLE onprc_billing.aliases ADD PPQDate TIMESTAMP Null;

CREATE TABLE onprc_billing.ogasynch (
	lastIndexed timestamp NULL,
	modifiedBy int NULL,
	container ENTITYID NOT NULL,
	modified timestamp NULL,
	created timestamp NULL,
	entityId ENTITYID NOT NULL,
	createdBy int NULL,
	"ADFM EMP NUM" int NULL,
	"ADFM FULL NAME" varchar(4000) NULL,
	"ADFM LAST NAME" varchar(4000) NULL,
	"ADFM FIRST NAME" varchar(4000) NULL,
	"PI EMP NUM" int NULL,
	"PI FULL NAME" varchar(4000) NULL,
	"PI LAST NAME" varchar(4000) NULL,
	"PI FIRST NAME" varchar(4000) NULL,
	"PDFM EMP NUM" int NULL,
	"PDFM FULL NAME" varchar(4000) NULL,
	"PDFM LAST NAME" varchar(4000) NULL,
	"PDFM FIRST NAME" varchar(4000) NULL,
	"AGENCY AWARD NUMBER" varchar(4000) NULL,
	"OGA AWARD NUMBER" varchar(4000) NULL,
	"OGA AWARD TYPE" varchar(4000) NULL,
	"OGA PROJECT NUMBER" varchar(4000) NULL,
	"ALIAS" int NULL,
	"ALIAS ENABLED FLAG" boolean NULL,
	"ALIAS ENABLED FLAG_MVIndicator" varchar(50) NULL,
	"PROJECT DESCRIPTION" varchar(4000) NULL,
	"APPLICATION TYPE" int NULL,
	"ACTIVITY TYPE" varchar(4000) NULL,
	"AWARD NUMBER" varchar(4000) NULL,
	"AWARD SUFFIX" varchar(4000) NULL,
	"ORG" varchar(4000) NULL,
	"CURRENT BUDGET START DATE" timestamp NULL,
	"CURRENT BUDGET END DATE" timestamp NULL,
	"PROJECT TITLE" varchar(4000) NULL,
	"PPQ CODE" varchar(4000) NULL,
	"PPQ DATE" timestamp NULL,
	"IACUC NUMBER" varchar(4000) NULL,
	"AWARD STATUS" varchar(4000) NULL,
	"PROJECT STATUS" varchar(4000) NULL,
	"AWARD ID" int NULL,
	"PROJECT ID" int NULL,
	"BURDEN SCHEDULE" varchar(4000) NULL,
	"BURDEN RATE" double precision NULL,
	"faRate" double precision NULL,
	"Key" serial NOT NULL
);

-- Adding additional Fields for Alias insert from OGA Synch
--Rerunning and it does not appear in Build
--2020-03-4 Revision to add this to UAT
ALTER TABLE onprc_billing.aliases ADD ApplicationType VarChar(255) Null;

ALTER TABLE onprc_billing.aliases ADD ApplicationTypeDescription VarChar(255) Null;

ALTER TABLE onprc_billing.aliases ADD AwardStatus VARCHAR(100) Null;

ALTER TABLE onprc_billing.aliases ADD AwardID VARCHAR(100) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS ApplicationType CASCADE;
ALTER TABLE onprc_billing.aliases ADD ApplicationType VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases ADD ProjectID VARCHAR(100) Null;

ALTER TABLE onprc_billing.aliases ADD ActivityType VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases ADD AwardNumber VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases ADD AwardSuffix VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases ADD Org VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases ADD ADFMEmpNum VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases ADD ADFMFullName VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases ADD ActivityTypeDescription VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases ADD FundingSourceNumber VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases ADD FundingSourceName VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS Org CASCADE;
ALTER TABLE onprc_billing.aliases ADD Org VARCHAR(255) Null;

CREATE OR REPLACE FUNCTION onprc_billing.AliasCleanup202004()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    --Handles active non OGA Aliases
    UPDATE onprc_billing.aliases a
    SET projectStatus = 'Active', comments = 'In Use - Non ONPRC Alias', category = 'OHSU GL'
    FROM onprc_billing.projectAccountHistory p
    WHERE p.account = a.alias
      AND p.enddate >= CURRENT_TIMESTAMP AND a.alias NOT LIKE '9%';

    -- updates the alias dataset setting end date and comment for disabled aliases
    UPDATE onprc_billing.aliases a
    SET dateDisabled = '2020-04-01', Comments = 'Alias Disabled'
    WHERE aliasEnabled = 'N' OR aliasEnabled = 'n';

    UPDATE onprc_billing.aliases a1
    SET projectStatus = 'Non Active GL', aliasEnabled = 'n', datedisabled = CURRENT_TIMESTAMP, comments = 'GL Alias Not Active entered Previously'
    WHERE a1.alias NOT LIKE '9%' AND (lower(a1.comments) != lower('In Use - Non ONPRC Alias') OR a1.comments IS NULL);

    UPDATE onprc_billing.aliases a2
    SET dateDisabled = CURRENT_TIMESTAMP, comments = 'Expired Alias', aliasEnabled = 'n'
    WHERE a2.budgetEndDate <= CURRENT_TIMESTAMP;

    UPDATE onprc_billing.aliases a4
    SET dateDisabled = CURRENT_TIMESTAMP, comments = 'Grant Closed', projectStatus = 'Grant Closed', aliasEnabled = 'N'
    FROM onprc_billing.ogasynch s
    WHERE CAST(a4.alias AS varchar(50)) = CAST(s."ALIAS" AS varchar(50))
      AND a4.dateDisabled IS NULL AND lower(a4.projectstatus) IN (lower('Archived'), lower('Closed'), lower('IM PURGEd'));

    --Remove Records not associated with ONPRC
    DELETE FROM onprc_billing.aliases
    WHERE alias IN (
        SELECT a.alias
        FROM onprc_billing.aliases a
        LEFT OUTER JOIN onprc_billing.projectAccountHistory p ON a.alias = p.account
        WHERE p.account IS NULL AND a.dateDisabled IS NOT NULL
    );
END;
$$;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS ApplicationType CASCADE;
ALTER TABLE onprc_billing.aliases ADD ApplicationType VarChar(255) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS ApplicationTypeDescription CASCADE;
ALTER TABLE onprc_billing.aliases ADD ApplicationTypeDescription VarChar(255) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS AwardStatus CASCADE;
ALTER TABLE onprc_billing.aliases ADD AwardStatus VARCHAR(100) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS AwardID CASCADE;
ALTER TABLE onprc_billing.aliases ADD AwardID VARCHAR(100) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS ApplicationType CASCADE;
ALTER TABLE onprc_billing.aliases ADD ApplicationType VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS ProjectID CASCADE;
ALTER TABLE onprc_billing.aliases ADD ProjectID VARCHAR(100) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS ActivityType CASCADE;
ALTER TABLE onprc_billing.aliases ADD ActivityType VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS AwardNumber CASCADE;
ALTER TABLE onprc_billing.aliases ADD AwardNumber VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS AwardSuffix CASCADE;
ALTER TABLE onprc_billing.aliases ADD AwardSuffix VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS Org CASCADE;
ALTER TABLE onprc_billing.aliases ADD Org VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS ADFMEmpNum CASCADE;
ALTER TABLE onprc_billing.aliases ADD ADFMEmpNum VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS ADFMFullName CASCADE;
ALTER TABLE onprc_billing.aliases ADD ADFMFullName VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS ActivityTypeDescription CASCADE;
ALTER TABLE onprc_billing.aliases ADD ActivityTypeDescription VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS FundingSourceNumber CASCADE;
ALTER TABLE onprc_billing.aliases ADD FundingSourceNumber VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS FundingSourceName CASCADE;
ALTER TABLE onprc_billing.aliases ADD FundingSourceName VARCHAR(255) Null;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS Org CASCADE;
ALTER TABLE onprc_billing.aliases ADD Org VARCHAR(255) Null;

DROP FUNCTION IF EXISTS onprc_billing.OGA_RemoveRecords();

CREATE OR REPLACE FUNCTION onprc_billing.OGA_RemoveRecords()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM onprc_billing.aliases
    WHERE lower(category) != lower('OHSU GL');
END;
$$;

DROP FUNCTION IF EXISTS onprc_ehr.RateCalc(varchar, float8, float8, date, float8);

CREATE OR REPLACE FUNCTION onprc_ehr.RateCalc
(
    v_alias varchar(20),
    v_chargeId float8,
    v_project float8,
    v_startDate date,
    v_baseSubsidyVal float8
)
RETURNS float8
LANGUAGE plpgsql
AS $$
DECLARE
    unitCostVal float8;
    projectExemption float8;
    projectMultipler float8;
    unitCost float8;
    NonOGAAlias varchar(20);
    blankAliasType varchar(20);
    baseSubsidy float8;
    subsidy float8;
    faRate float8;
    removeSubsidy smallint;
    aliasRaiseFA smallint;
    chargeRaiseFA smallint;
BEGIN
    v_baseSubsidyVal := .47;
    basesubsidy := .47;
    unitCost := 1000;
    subsidy := v_baseSubsidyVal;

    -- Each lookup below is a scalar subquery, matching the SQL Server original's "SET @x = (SELECT ...)".
    -- Both dialects yield NULL when nothing matches and raise an error when more than one row matches.
    -- Do not substitute LIMIT 1: overlapping date ranges would then silently pick an arbitrary rate.
    projectExemption := (
        SELECT cr.unitcost
        FROM onprc_billing.chargeRateExemptions cr
        WHERE cr.chargeId = v_chargeId::integer
          AND cr.project = v_project::integer
          AND cr.startDate < v_startDate
          AND ((v_startDate <= cr.endDate) OR (cr.enddate IS NULL)));

    projectMultipler := (
        SELECT pm.multiplier
        FROM onprc_billing.projectMultipliers pm
        WHERE pm.account = v_alias
          AND pm.startdate <= v_startDate
          AND ((pm.enddate >= v_startDate) OR (pm.enddate IS NULL)));

    NonOGAAlias := (
        SELECT a.category
        FROM onprc_billing.aliases a
        WHERE a.alias = v_alias
          AND (a.budgetStartDate < v_startDate AND a.budgetEndDate > v_startDate));

    blankAliasType := (
        SELECT a.aliasType
        FROM onprc_billing.aliases a
        WHERE a.alias = v_alias
          AND (a.budgetStartDate < v_startDate AND a.budgetEndDate > v_startDate));

    removeSubsidy := (
        SELECT CASE WHEN t.removeSubsidy = true THEN 1 ELSE 0 END
        FROM onprc_billing.aliases a
        JOIN onprc_billing.aliasTypes t ON a.aliasType = t.aliasType
        WHERE a.alias = v_alias
          AND (a.budgetStartDate < v_startDate AND a.budgetEndDate > v_startDate));

    chargeRaiseFA := (
        SELECT CASE WHEN c.canRaiseFA = true THEN 1 ELSE 0 END
        FROM onprc_billing.chargeableItems c
        JOIN onprc_billing.chargeRates cr ON c.rowId = cr.chargeId
        WHERE cr.chargeId = v_chargeId::integer
          AND (cr.StartDate < v_startDate AND cr.EndDate > v_startDate));

    aliasRaiseFA := (
        SELECT CASE WHEN t.canRaiseFA = true THEN 1 ELSE 0 END
        FROM onprc_billing.aliases a
        JOIN onprc_billing.aliasTypes t ON a.aliasType = t.aliasType
        WHERE a.alias = v_alias
          AND (a.budgetStartDate < v_startDate AND a.budgetEndDate > v_startDate));

    faRate := (
        SELECT a.faRate
        FROM onprc_billing.aliases a
        WHERE a.alias = v_alias
          AND (a.budgetStartDate < v_startDate AND a.budgetEndDate > v_startDate));

    unitCost := (
        SELECT r.unitcost
        FROM onprc_billing.chargeRates r
        WHERE r.chargeID = v_chargeId::integer
          AND r.startDate <= v_startDate
          AND ((r.enddate >= v_startDate) OR r.enddate IS NULL));

    unitCostVal := CASE
        WHEN projectExemption IS NOT NULL THEN projectExemption
        WHEN projectMultipler IS NOT NULL THEN projectMultipler * unitCost
        WHEN unitCost IS NULL THEN NULL
        WHEN NonOGAAlias IS NOT NULL AND lower(NonOGAAlias) != lower('OGA') THEN unitCost
        WHEN blankAliasType IS NULL THEN NULL
        WHEN (removeSubsidy = 1 AND (aliasRaiseFA = 1 AND chargeRaiseFA = 1)) THEN
            ((unitCost / (1 - COALESCE(subsidy, 0))) * (CASE WHEN (faRate IS NOT NULL AND faRate < baseSubsidy) THEN (1 + baseSubsidy / (1 + faRate)) ELSE 1 END))
        WHEN (removeSubsidy = 1 AND aliasRaiseFA = 0) THEN
            (unitCost / (1 - COALESCE(subsidy, 0)))
        WHEN (removeSubsidy = 0 AND (aliasRaiseFA = 1 AND chargeRaiseFA = 1)) THEN
            (unitCost * (CASE WHEN (faRate IS NOT NULL AND faRate = 0) THEN (1 + Subsidy / (1 + faRate)) ELSE 1 END))
        WHEN (removeSubsidy = 0 AND (aliasRaiseFA = 1 AND chargeRaiseFA = 1)) THEN
            (unitCost * (CASE WHEN (faRate IS NOT NULL AND faRate < Subsidy) THEN (1 + Subsidy / (1 + faRate)) ELSE 1 END))
        ELSE unitCost
    END;

    RETURN unitCostVal;
END;
$$;

DROP FUNCTION IF EXISTS onprc_billing.ClearOGASync();

CREATE OR REPLACE FUNCTION onprc_billing.ClearOGASync()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM onprc_billing.ogasynch;
END;
$$;

/* 22.xxx SQL scripts */

ALTER TABLE onprc_billing.aliases ADD OriginatingAgencyAwardNum VarChar(255) Null;
ALTER TABLE onprc_billing.ogaSynch ADD ORIGINATING_AGENCY_AWARD_NUM VarChar(255) Null;

--20220406 update of SP for insert
DROP FUNCTION IF EXISTS onprc_billing.oga_InsertRecords();

CREATE OR REPLACE FUNCTION onprc_billing.oga_InsertRecords()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO onprc_billing.aliases (
        alias,
        aliasEnabled,
        projectNumber,
        grantNumber,
        agencyAwardNumber,
        investigatorId,
        investigatorName,
        fiscalAuthority,
        container,
        createdBy,
        created,
        category,
        faRate,
        faSchedule,
        budgetStartDate,
        budgetEndDate,
        projectTitle,
        projectDescription,
        projectStatus,
        aliasType,
        COMMENTS,
        PPQNumber,
        PPQDate,
        AwardStatus,
        AwardID,
        ApplicationType,
        ProjectID,
        ActivityType,
        AwardNumber,
        AwardSuffix,
        ADFMEmpNum,
        ADFMFullName,
        Org,
        OriginatingAgencyAwardNum
    )
    SELECT
        CAST(o."ALIAS" AS varchar(200)),
        CASE
            WHEN o."ALIAS ENABLED FLAG" = true THEN 'y'
            WHEN o."ALIAS ENABLED FLAG" = false THEN 'n'
            ELSE NULL
        END AS AliasEnabled,
        o."OGA PROJECT NUMBER",
        o."OGA AWARD NUMBER",
        o."AGENCY AWARD NUMBER",
        i.rowId,
        o."PI FULL NAME",
        f.rowid,
        '0F8BB08E-E4BF-102F-B89B-5107380A5B61'::entityid,
        1003,
        CURRENT_TIMESTAMP,
        'OGA',
        o."faRate",
        o."BURDEN SCHEDULE",
        o."CURRENT BUDGET START DATE",
        o."CURRENT BUDGET END DATE",
        o."PROJECT TITLE",
        o."PROJECT DESCRIPTION",
        o."PROJECT STATUS",
        o."OGA AWARD TYPE",
        'ENTERED BY ISE',
        o."PPQ CODE",
        o."PPQ DATE",
        o."AWARD STATUS",
        CAST(o."AWARD ID" AS varchar(100)),
        CAST(o."APPLICATION TYPE" AS varchar(255)),
        CAST(o."PROJECT ID" AS varchar(100)),
        o."OGA AWARD TYPE",
        o."AWARD NUMBER",
        o."AWARD SUFFIX",
        CAST(o."ADFM EMP NUM" AS varchar(255)),
        o."ADFM FULL NAME",
        o."ORG",
        o.ORIGINATING_AGENCY_AWARD_NUM
    FROM onprc_billing.ogasynch o
    LEFT OUTER JOIN onprc_ehr.investigators i ON CAST(o."PI EMP NUM" AS varchar(100)) = i.employeeid AND i.datedisabled IS NULL
    LEFT OUTER JOIN onprc_billing.fiscalAuthorities f ON f.employeeId = CAST(o."PDFM EMP NUM" AS varchar(100)) AND f.active = true;
END;
$$;

ALTER TABLE onprc_billing.aliases DROP COLUMN IF EXISTS OriginatingAgencyAwardNum CASCADE;
ALTER TABLE onprc_billing.ogaSynch DROP COLUMN IF EXISTS ORIGINATING_AGENCY_AWARD_NUM CASCADE;
ALTER TABLE onprc_billing.aliases ADD OriginatingAgencyAwardNum VarChar(255) Null;
ALTER TABLE onprc_billing.ogaSynch ADD ORIGINATING_AGENCY_AWARD_NUM VarChar(255) Null;

/* 23.xxx SQL scripts */

DROP FUNCTION IF EXISTS onprc_billing.UpdateClinPathEndDate();

CREATE OR REPLACE FUNCTION onprc_billing.UpdateClinPathEndDate()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE studyDataset.c6d199_clinpathruns
    SET datefinalized = date
    WHERE dateFinalized IS NULL AND date > '2023-05-01' AND qcstate = 18;
END;
$$;

