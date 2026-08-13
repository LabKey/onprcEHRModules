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

-- this table contains one row each time a billing run is performed, which gleans items to be charged
-- from a variety of sources and snapshots them into invoicedItems
CREATE TABLE onprc_billing.invoiceRuns (
    rowId SERIAL,
    runDate TIMESTAMP,
    billingPeriodStart TIMESTAMP,
    billingPeriodEnd TIMESTAMP,
    invoiceNumber varchar(200),
    dataSources varchar(1000),
    comment varchar(4000),
    status varchar(200),
    objectid ENTITYID NOT NULL,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created TIMESTAMP,
    modifiedBy USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_invoiceRuns PRIMARY KEY (objectid)
);

-- this table contains a snapshot of items actually invoiced, which will draw from many places in the animal record
CREATE TABLE onprc_billing.invoicedItems (
    rowId SERIAL,
    invoiceId ENTITYID,
    transactionNumber varchar(100),
    invoiceDate TIMESTAMP,
    id varchar(100),
    date TIMESTAMP,
    item varchar(500),
    itemCode varchar(100),
    category varchar(100),
    servicecenter varchar(200),
    project int,
    debitedaccount varchar(100),
    creditedaccount varchar(100),
    faid int,
    investigatorId int,
    lastName varchar(100),
    firstName varchar(100),
    department varchar(100),
    mailcode varchar(20),
    contactPhone varchar(30),
    chargeId int,
    cageId int,
    objectid ENTITYID NOT NULL,
    quantity double precision,
    unitcost double precision,
    totalcost double precision,
    credit BOOLEAN,
    rateId int,
    exemptionId int,
    creditAccountId int,
    comment varchar(4000),
    transactionType varchar(10),
    sourceRecord varchar(200),
    sourceRecord2 varchar(100),
    issueId int,
    chargeCategory varchar(100),
    billingId int,
    invoiceNumber int,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created TIMESTAMP,
    modifiedBy USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_invoicedItems PRIMARY KEY (objectid)
);

-- this table contains a list of all potential items that can be charged. it maps between the integer ID
-- and a descriptive name. it does not contain any fee information
CREATE TABLE onprc_billing.chargeableItems (
    rowId SERIAL,
    name varchar(200),
    shortName varchar(100),
    category varchar(200),
    comment varchar(4000),
    itemCode varchar(100),
    departmentCode varchar(100),
    allowsCustomUnitCost BOOLEAN DEFAULT FALSE,
    allowBlankId BOOLEAN DEFAULT FALSE,
    canRaiseFA BOOLEAN,
    active BOOLEAN DEFAULT TRUE,
    startDate TIMESTAMP,
    endDate TIMESTAMP,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created TIMESTAMP,
    modifiedBy USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_chargeableItems PRIMARY KEY (rowId)
);

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

-- this table contains a list of the current charges for each item in onprc_billing.chargeableItems
-- it will retain historic information, so we can accurately determine 'cost at the time'
CREATE TABLE onprc_billing.chargeRates (
    rowId SERIAL,
    chargeId int,
    unitcost double precision,
    subsidy double precision,
    startDate TIMESTAMP,
    endDate TIMESTAMP,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created TIMESTAMP,
    modifiedBy USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_chargeRates PRIMARY KEY (rowId)
);

-- contains records of project-specific exemptions to chargeRates
CREATE TABLE onprc_billing.chargeRateExemptions (
    rowId SERIAL,
    project int,
    chargeId int,
    unitcost double precision,
    remark varchar(4000),
    startDate TIMESTAMP,
    endDate TIMESTAMP,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created TIMESTAMP,
    modifiedBy USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_chargeRateExemptions PRIMARY KEY (rowId)
);

-- maps the account to be credited for each charged item
CREATE TABLE onprc_billing.creditAccount (
    rowId SERIAL,
    chargeId int,
    account varchar(100),
    startDate TIMESTAMP,
    endDate TIMESTAMP,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created TIMESTAMP,
    modifiedBy USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_creditAccount PRIMARY KEY (rowId)
);

-- this table contains records of misc charges that have happened that cannot otherwise be
-- automatically inferred from the record
CREATE TABLE onprc_billing.miscCharges (
    id varchar(100),
    date TIMESTAMP,
    project integer,
    debitedaccount varchar(200),
    chargeType varchar(200),
    creditedaccount varchar(100),
    chargeId int,
    item varchar(500),
    quantity double precision,
    unitcost double precision,
    comment varchar(4000),
    billingDate TIMESTAMP,
    category varchar(100),
    invoiceId ENTITYID,
    sourceInvoicedItem ENTITYID,
    chargeCategory varchar(100),
    issueId int,
    invoicedItemId ENTITYID,
    qcstate int,

    taskid ENTITYID,
    requestid ENTITYID,
    objectid ENTITYID NOT NULL,
    parentid ENTITYID,
    formSort integer,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created TIMESTAMP,
    modifiedBy USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_miscCharges PRIMARY KEY (objectid)
);

CREATE TABLE onprc_billing.miscChargesType (
    category varchar(100) NOT NULL,

    CONSTRAINT PK_miscChargesType PRIMARY KEY (category)
);

INSERT INTO onprc_billing.miscChargesType (category) VALUES ('Adjustment');
INSERT INTO onprc_billing.miscChargesType (category) VALUES ('Reversal');

-- this table details how to calculate lease fees, and produces a list of charges over a billing period
-- no fee info is contained
CREATE TABLE onprc_billing.leaseFeeDefinition (
    rowId SERIAL,
    minAge int,
    maxAge int,

    assignCondition int,
    releaseCondition int,
    chargeId int,
    chargeunit varchar(100),

    active BOOLEAN DEFAULT TRUE,
    startDate TIMESTAMP,
    endDate TIMESTAMP,
    objectid ENTITYID,
    createdBy int,
    created TIMESTAMP,
    modifiedBy int,
    modified TIMESTAMP,

    CONSTRAINT PK_leaseFeeDefinition PRIMARY KEY (rowId)
);

CREATE TABLE onprc_billing.perDiemFeeDefinition (
    rowId SERIAL,
    chargeId int,
    housingType int,
    housingDefinition int,
    tier varchar(100),
    canChargeInfants BOOLEAN DEFAULT FALSE,

    active BOOLEAN DEFAULT TRUE,
    startDate TIMESTAMP,
    endDate TIMESTAMP,
    objectid ENTITYID,
    createdBy int,
    created TIMESTAMP,
    modifiedBy int,
    modified TIMESTAMP,

    CONSTRAINT PK_perDiemFeeDefinition PRIMARY KEY (rowId)
);

CREATE TABLE onprc_billing.slaPerDiemFeeDefinition (
    rowid SERIAL,
    chargeid int,
    cagetype varchar(100),
    cagesize varchar(100),
    species varchar(100),

    active BOOLEAN,
    startDate TIMESTAMP,
    endDate TIMESTAMP,
    objectid ENTITYID,
    createdby int,
    created TIMESTAMP,
    modifiedby int,
    modified TIMESTAMP,

    CONSTRAINT PK_slaPerDiemFeeDefinition PRIMARY KEY (rowid)
);

CREATE TABLE onprc_billing.procedureFeeDefinition (
    rowid SERIAL,
    procedureId int,
    chargetype varchar(100),
    assistingStaff varchar(100),
    chargeId int,

    active BOOLEAN DEFAULT TRUE,
    startDate TIMESTAMP,
    endDate TIMESTAMP,
    objectid ENTITYID,
    createdBy int,
    created TIMESTAMP,
    modifiedBy int,
    modified TIMESTAMP,

    CONSTRAINT PK_procedureFeeDefinition PRIMARY KEY (rowId)
);

CREATE TABLE onprc_billing.labworkFeeDefinition (
    rowid SERIAL,
    servicename varchar(200),
    chargeType varchar(100),
    chargeId int,

    active BOOLEAN DEFAULT TRUE,
    startDate TIMESTAMP,
    endDate TIMESTAMP,
    objectid ENTITYID,
    createdBy int,
    created TIMESTAMP,
    modifiedBy int,
    modified TIMESTAMP,

    CONSTRAINT PK_labworkFeeDefinition PRIMARY KEY (rowId)
);

CREATE TABLE onprc_billing.medicationFeeDefinition (
    rowid SERIAL,
    chargeId int,
    code varchar(100),
    route varchar(100),

    active BOOLEAN DEFAULT TRUE,
    startDate TIMESTAMP,
    endDate TIMESTAMP,
    objectid ENTITYID,
    createdBy int,
    created TIMESTAMP,
    modifiedBy int,
    modified TIMESTAMP,

    CONSTRAINT PK_medicationFeeDefinition PRIMARY KEY (rowId)
);

CREATE TABLE onprc_billing.fiscalAuthorities (
    rowid SERIAL,
    lastName varchar(100),
    firstName varchar(100),
    faid varchar(100),
    position varchar(100),
    address varchar(500),
    city varchar(100),
    state varchar(100),
    country varchar(100),
    zip varchar(100),
    phoneNumber varchar(100),
    employeeId varchar(100),

    active BOOLEAN DEFAULT TRUE,
    objectid ENTITYID,
    createdBy int,
    created TIMESTAMP,
    modifiedBy int,
    modified TIMESTAMP,

    CONSTRAINT pk_fiscalAuthorities PRIMARY KEY (rowId)
);

CREATE TABLE onprc_billing.grants (
    rowid SERIAL,
    grantNumber varchar(100),
    agencyAwardNumber varchar(200),
    investigatorId int,
    investigatorName varchar(200),
    title varchar(500),
    startDate TIMESTAMP,
    endDate TIMESTAMP,
    fiscalAuthority int,
    applicationType varchar(100),
    activityType varchar(100),
    fundingAgency varchar(200),
    grantType varchar(200),
    awardStatus varchar(100),
    budgetStartDate TIMESTAMP,
    budgetEndDate TIMESTAMP,
    comment text,
    ogaAwardId int,

    container ENTITYID,
    createdBy int,
    created TIMESTAMP,
    modifiedBy int,
    modified TIMESTAMP,

    CONSTRAINT PK_grants PRIMARY KEY (rowid),
    CONSTRAINT UNIQUE_grants UNIQUE (container, grantNumber)
);

CREATE TABLE onprc_billing.grantProjects (
    rowid SERIAL,
    projectNumber varchar(200),
    grantNumber varchar(200),
    fundingAgency varchar(200),
    grantType varchar(200),
    agencyAwardNumber varchar(200),
    investigatorId int,
    investigatorName varchar(200),
    projectTitle varchar(4000),
    projectDescription varchar(4000),
    organization varchar(200),
    protocolNumber varchar(100),
    projectStatus varchar(100),
    ogaProjectId int,

    budgetStartDate TIMESTAMP,
    budgetEndDate TIMESTAMP,
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
    rowid SERIAL,
    protocol varchar(200),
    grantNumber varchar(200),
    projectNumber varchar(200),

    startdate TIMESTAMP,
    enddate TIMESTAMP,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created TIMESTAMP,
    modifiedBy USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_iacucFundingSources PRIMARY KEY (rowid)
);

CREATE TABLE onprc_billing.projectAccountHistory (
    rowid SERIAL,
    project int,
    account varchar(200),
    startdate TIMESTAMP,
    enddate TIMESTAMP,
    objectid ENTITYID,
    createdby USERID,
    created TIMESTAMP,
    modifiedby USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_projectAccountHistory PRIMARY KEY (rowid)
);

CREATE INDEX IDX_projectAccountHistory_project_enddate ON onprc_billing.projectAccountHistory (project, enddate);

CREATE TABLE onprc_billing.aliases (
    rowid SERIAL,
    alias varchar(200),
    category varchar(100),
    aliasEnabled varchar(100),
    projectNumber varchar(200),
    grantNumber varchar(200),
    agencyAwardNumber varchar(200),
    investigatorId int,
    investigatorName varchar(200),
    fiscalAuthority int,
    fiscalAuthorityName varchar(200),
    budgetStartDate TIMESTAMP,
    budgetEndDate TIMESTAMP,
    faRate double precision,
    faSchedule varchar(200),
    projectTitle varchar(1000),
    projectDescription varchar(1000),
    projectStatus varchar(200),
    aliasType varchar(100),

    dateDisabled TIMESTAMP,
    COMMENTS varchar(255),
    PPQNumber varchar(25),
    PPQDate TIMESTAMP,
    ApplicationTypeDescription varchar(255),
    AwardStatus varchar(100),
    AwardID varchar(100),
    ApplicationType varchar(255),
    ProjectID varchar(100),
    ActivityType varchar(255),
    ActivityTypeDescription varchar(255),
    AwardNumber varchar(255),
    AwardSuffix varchar(255),
    ADFMEmpNum varchar(255),
    ADFMFullName varchar(255),
    FUndingSourceNumber varchar(255),
    FUndingSourceName varchar(255),
    OriginatingAgencyAwardNum varchar(255),
    Org varchar(255),

    container ENTITYID NOT NULL,
    createdBy USERID,
    created TIMESTAMP,
    modifiedBy USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_aliases PRIMARY KEY (rowid)
);

CREATE INDEX IDX_aliases ON onprc_billing.aliases (container, alias);

CREATE TABLE onprc_billing.aliasCategories (
    category varchar(100),

    CONSTRAINT PK_aliasCategories PRIMARY KEY (category)
);

INSERT INTO onprc_billing.aliasCategories (category) VALUES ('OGA');
INSERT INTO onprc_billing.aliasCategories (category) VALUES ('Other');
INSERT INTO onprc_billing.aliasCategories (category) VALUES ('GL');
INSERT INTO onprc_billing.aliasCategories (category) VALUES ('Non-Syncing');

CREATE TABLE onprc_billing.aliasTypes (
    aliasType varchar(500) NOT NULL,
    removeSubsidy BOOLEAN,
    canRaiseFA BOOLEAN,

    createdBy integer,
    created TIMESTAMP,
    modifiedBy integer,
    modified TIMESTAMP,

    CONSTRAINT PK_aliasTypes PRIMARY KEY (aliasType)
);

CREATE TABLE onprc_billing.projectMultipliers (
    rowid SERIAL,
    account varchar(100),
    multiplier double precision,

    startdate TIMESTAMP,
    enddate TIMESTAMP,
    comment varchar(4000),

    container ENTITYID,
    createdBy integer,
    created TIMESTAMP,
    modifiedBy integer,
    modified TIMESTAMP,

    CONSTRAINT PK_projectMultipliers PRIMARY KEY (rowid)
);

CREATE TABLE onprc_billing.chargeUnits (
    chargetype varchar(100) NOT NULL,
    servicecenter varchar(100),
    shownInBlood BOOLEAN DEFAULT FALSE,
    shownInLabwork BOOLEAN DEFAULT FALSE,
    shownInMedications BOOLEAN DEFAULT FALSE,
    shownInProcedures BOOLEAN DEFAULT FALSE,

    active BOOLEAN DEFAULT TRUE,
    container ENTITYID,
    createdBy int,
    created TIMESTAMP,
    modifiedBy int,
    modified TIMESTAMP,

    CONSTRAINT PK_chargeUnits PRIMARY KEY (chargetype)
);

CREATE TABLE onprc_billing.chargeUnitAccounts (
    rowid SERIAL,
    chargetype varchar(100),
    account varchar(100),
    startdate TIMESTAMP,
    enddate TIMESTAMP,

    container ENTITYID,
    createdBy int,
    created TIMESTAMP,
    modifiedBy int,
    modified TIMESTAMP,

    CONSTRAINT PK_chargeUnitAccounts PRIMARY KEY (rowid)
);

CREATE TABLE onprc_billing.dataAccess (
    rowId SERIAL,
    userid int,
    investigatorId int,
    project int,
    allData BOOLEAN,

    container ENTITYID NOT NULL,
    createdBy int,
    created TIMESTAMP,
    modifiedBy int,
    modified TIMESTAMP,

    CONSTRAINT PK_dataAccess PRIMARY KEY (rowId)
);

-- Created 8/25/2016 gjones. Controls the inflation factor applied to ONPRC rates.
-- Created as AnnualInflationRate on SQL Server and renamed to AnnualRateChange in the same script run.
CREATE TABLE onprc_billing.AnnualRateChange (
    rowid SERIAL,
    billingYear varchar(10) NOT NULL,
    inflationRate numeric(18,4),
    startDate TIMESTAMP,
    endDate TIMESTAMP,

    createdBy integer,
    created TIMESTAMP,
    modifiedBy integer,
    modified TIMESTAMP,

    CONSTRAINT PK_AnnualRateChange_RowID PRIMARY KEY (rowid)
);

-- Created 4-26-2017 R.Blasa
CREATE TABLE onprc_billing.MergeChargtypeUpdates (
    rowid SERIAL,
    ProjectName varchar(50) NOT NULL,
    Protocol varchar(100) NOT NULL,
    ChargeType varchar(50) NOT NULL,
    objectid ENTITYID,
    startDate TIMESTAMP,
    endDate TIMESTAMP,

    CONSTRAINT PK_MergeType PRIMARY KEY (rowid)
);

-- Staging table loaded by the OGASync2020Admin ETL from the external OGA schema. The bracketed,
-- space-separated SQL Server column names are preserved verbatim, so they must stay double-quoted here.
CREATE TABLE onprc_billing.ogasynch (
    lastIndexed TIMESTAMP NULL,
    modifiedBy int NULL,
    container ENTITYID NOT NULL,
    modified TIMESTAMP NULL,
    created TIMESTAMP NULL,
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
    "ALIAS ENABLED FLAG" BOOLEAN NULL,
    "ALIAS ENABLED FLAG_MVIndicator" varchar(50) NULL,
    "PROJECT DESCRIPTION" varchar(4000) NULL,
    "APPLICATION TYPE" int NULL,
    "ACTIVITY TYPE" varchar(4000) NULL,
    "AWARD NUMBER" varchar(4000) NULL,
    "AWARD SUFFIX" varchar(4000) NULL,
    "ORG" varchar(4000) NULL,
    "CURRENT BUDGET START DATE" TIMESTAMP NULL,
    "CURRENT BUDGET END DATE" TIMESTAMP NULL,
    "PROJECT TITLE" varchar(4000) NULL,
    "PPQ CODE" varchar(4000) NULL,
    "PPQ DATE" TIMESTAMP NULL,
    "IACUC NUMBER" varchar(4000) NULL,
    "AWARD STATUS" varchar(4000) NULL,
    "PROJECT STATUS" varchar(4000) NULL,
    "AWARD ID" int NULL,
    "PROJECT ID" int NULL,
    "BURDEN SCHEDULE" varchar(4000) NULL,
    "BURDEN RATE" double precision NULL,
    faRate double precision NULL,
    key SERIAL,
    ORIGINATING_AGENCY_AWARD_NUM varchar(255) NULL,

    CONSTRAINT PK_ogasynch PRIMARY KEY (key) -- Note: no PK on SQL Server, where [Key] is just an IDENTITY column
);

/*
** onprc_ehr.RateCalc
**
** Ported from the SQL Server scalar function created by onprc_billing-20.515-20.516.sql. It lives in
** the onprc_ehr schema (not onprc_billing) because ONPRC_BillingModule registers it as a passthrough
** method against onprc_ehr:
**     QueryService.get().registerPassthroughMethod("RateCalc", "onprc_ehr", JdbcType.DOUBLE, 5, 5);
** and it is called from onprc_billing queries such as leaseFeeRates_2020.sql and miscChargesWithRates.sql.
**
** The startDate parameter is declared TIMESTAMP rather than DATE (SQL Server used DATE). PostgreSQL only
** casts DATE -> TIMESTAMP implicitly, not the reverse, so a TIMESTAMP parameter accepts callers passing
** either a date or a datetime column; a DATE parameter would fail to resolve for the latter.
**
** removeSubsidy and canRaiseFA are BOOLEAN here (bit on SQL Server), so they are cast to int for the
** = 1 / = 0 comparisons the original logic is written against.
*/
CREATE OR REPLACE FUNCTION onprc_ehr.RateCalc(
    p_alias varchar,
    p_chargeId double precision,
    p_project double precision,
    p_startDate TIMESTAMP,
    p_baseSubsidyVal double precision
)
RETURNS double precision
LANGUAGE plpgsql
AS $$
DECLARE
    v_unitCostVal       double precision;
    v_projectExemption  double precision;
    v_projectMultiplier double precision;
    v_unitCost          double precision;
    v_nonOGAAlias       varchar(20);
    v_blankAliasType    varchar(20);
    v_baseSubsidy       double precision;
    v_subsidy           double precision;
    v_faRate            double precision;
    v_removeSubsidy     smallint;
    v_aliasRaiseFA      smallint;
    v_chargeRaiseFA     smallint;
BEGIN
    -- The base subsidy is also defined as a global in the LabKey Java code in onprc_ehr; if the base rate
    -- changes, the value needs to be updated in both places. Note the incoming p_baseSubsidyVal is
    -- deliberately ignored, matching the SQL Server function, which overwrote its own parameter.
    v_baseSubsidy := .47;
    v_subsidy := .47;
    v_unitCost := 1000;

    -- determine if there is a project level exemption
    SELECT cr.unitcost INTO v_projectExemption
    FROM onprc_billing.chargeRateExemptions cr
    WHERE cr.chargeId = p_chargeId
      AND cr.project = p_project
      AND cr.startDate < p_startDate
      AND ((p_startDate <= cr.endDate) OR (cr.endDate IS NULL));

    -- determine if there is a project level multiplier
    SELECT pm.multiplier INTO v_projectMultiplier
    FROM onprc_billing.projectMultipliers pm
    WHERE lower(pm.account) = lower(p_alias)
      AND pm.startdate <= p_startDate
      AND ((pm.enddate >= p_startDate) OR (pm.enddate IS NULL));

    -- determine if the alias is a non-OGA rate
    SELECT a.category INTO v_nonOGAAlias
    FROM onprc_billing.aliases a
    WHERE lower(a.alias) = lower(p_alias)
      AND (a.budgetStartDate < p_startDate AND a.budgetEndDate > p_startDate);

    -- determine if the alias type is blank
    SELECT a.aliasType INTO v_blankAliasType
    FROM onprc_billing.aliases a
    WHERE lower(a.alias) = lower(p_alias)
      AND (a.budgetStartDate < p_startDate AND a.budgetEndDate > p_startDate);

    -- determine whether the subsidy should be removed
    SELECT t.removeSubsidy::int INTO v_removeSubsidy
    FROM onprc_billing.aliases a
        JOIN onprc_billing.aliasTypes t ON lower(a.aliasType) = lower(t.aliasType)
    WHERE lower(a.alias) = lower(p_alias)
      AND (a.budgetStartDate < p_startDate AND a.budgetEndDate > p_startDate);

    -- determine whether raise F&A is true for the charge rate
    SELECT c.canRaiseFA::int INTO v_chargeRaiseFA
    FROM onprc_billing.chargeableItems c
        JOIN onprc_billing.chargeRates cr ON c.rowId = cr.chargeId
    WHERE cr.chargeId = p_chargeId
      AND (cr.startDate < p_startDate AND cr.endDate > p_startDate);

    -- determine whether raise F&A is true for the alias
    SELECT t.canRaiseFA::int INTO v_aliasRaiseFA
    FROM onprc_billing.aliases a
        JOIN onprc_billing.aliasTypes t ON lower(a.aliasType) = lower(t.aliasType)
    WHERE lower(a.alias) = lower(p_alias)
      AND (a.budgetStartDate < p_startDate AND a.budgetEndDate > p_startDate);

    -- get the F&A rate for the alias
    SELECT a.faRate INTO v_faRate
    FROM onprc_billing.aliases a
    WHERE lower(a.alias) = lower(p_alias)
      AND (a.budgetStartDate < p_startDate AND a.budgetEndDate > p_startDate);

    -- determine unit cost; null means there is no charge rate
    SELECT r.unitcost INTO v_unitCost
    FROM onprc_billing.chargeRates r
    WHERE r.chargeId = p_chargeId
      AND r.startDate <= p_startDate
      AND ((r.endDate >= p_startDate) OR r.endDate IS NULL);

    v_unitCostVal := CASE
        -- returns unit cost when there is an exemption at the project level
        WHEN v_projectExemption IS NOT NULL THEN v_projectExemption
        -- return value for a charge that has a pm multiplier
        WHEN v_projectMultiplier IS NOT NULL THEN v_projectMultiplier * v_unitCost
        -- where there is no unit cost listed return null
        WHEN v_unitCost IS NULL THEN NULL
        -- where the alias type is not OGA charge NIH rate
        WHEN v_nonOGAAlias IS NOT NULL AND lower(v_nonOGAAlias) != lower('OGA') THEN v_unitCost
        -- when alias type is not known then return null
        WHEN v_blankAliasType IS NULL THEN NULL

        WHEN (v_removeSubsidy = 1 AND (v_aliasRaiseFA = 1 AND v_chargeRaiseFA = 1))
            THEN ((v_unitCost / (1 - COALESCE(v_subsidy, 0))) * (CASE WHEN (v_faRate IS NOT NULL AND v_faRate < v_baseSubsidy) THEN (1 + v_baseSubsidy / (1 + v_faRate)) ELSE 1 END))

        WHEN (v_removeSubsidy = 1 AND v_aliasRaiseFA = 0)
            THEN (v_unitCost / (1 - COALESCE(v_subsidy, 0)))

        WHEN (v_removeSubsidy = 0 AND (v_aliasRaiseFA = 1 AND v_chargeRaiseFA = 1))
            THEN (v_unitCost * (CASE WHEN (v_faRate IS NOT NULL AND v_faRate = 0) THEN (1 + v_subsidy / (1 + v_faRate)) ELSE 1 END))

        -- Unreachable: duplicates the preceding WHEN condition. Retained to match the SQL Server function.
        WHEN (v_removeSubsidy = 0 AND (v_aliasRaiseFA = 1 AND v_chargeRaiseFA = 1))
            THEN (v_unitCost * (CASE WHEN (v_faRate IS NOT NULL AND v_faRate < v_subsidy) THEN (1 + v_subsidy / (1 + v_faRate)) ELSE 1 END))

        ELSE v_unitCost
    END;

    RETURN v_unitCostVal;
END;
$$;

/*
** OGASync2020Admin ETL step 1: reset the OGA staging table.
** Ported from onprc_billing-20.910-20.911.sql.
*/
CREATE OR REPLACE FUNCTION onprc_billing.ClearOGASync()
RETURNS integer
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM onprc_billing.ogasynch;

    RETURN 0;
END;
$$;

/*
** OGASync2020Admin ETL step 3: reset the alias dataset for insert from OGA, keeping GL accounts.
** Ported from onprc_billing-20.511-20.512.sql.
*/
CREATE OR REPLACE FUNCTION onprc_billing.OGA_RemoveRecords()
RETURNS integer
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM onprc_billing.aliases
    WHERE lower(category) != lower('OHSU GL');

    RETURN 0;
END;
$$;

/*
** OGASync2020Admin ETL step 4: insert aliases from the OGA staging table.
** Ported from the final SQL Server revision, onprc_billing-22.003-22.004.sql.
**
** The employee-id joins need explicit casts: ogasynch."PI EMP NUM" / "PDFM EMP NUM" are int while
** investigators.employeeid / fiscalAuthorities.employeeId are varchar, and PostgreSQL will not compare
** those implicitly the way SQL Server does. The same applies to the int -> varchar target columns.
*/
CREATE OR REPLACE FUNCTION onprc_billing.oga_InsertRecords()
RETURNS integer
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO onprc_billing.aliases
        (alias
        ,aliasEnabled
        ,projectNumber
        ,grantNumber
        ,agencyAwardNumber
        ,investigatorId
        ,investigatorName
        ,fiscalAuthority
        ,container
        ,createdBy
        ,created
        ,category
        ,faRate
        ,faSchedule
        ,budgetStartDate
        ,budgetEndDate
        ,projectTitle
        ,projectDescription
        ,projectStatus
        ,aliasType
        ,COMMENTS
        ,PPQNumber
        ,PPQDate
        ,AwardStatus
        ,AwardID
        ,ApplicationType
        ,ProjectID
        ,ActivityType
        ,AwardNumber
        ,AwardSuffix
        ,ADFMEmpNum
        ,ADFMFullName
        ,Org
        ,OriginatingAgencyAwardNum
        )
    SELECT
        o."ALIAS"::varchar
         ,CASE
              WHEN o."ALIAS ENABLED FLAG" IS TRUE THEN 'y'
              WHEN o."ALIAS ENABLED FLAG" IS FALSE THEN 'n'
          END AS AliasEnabled
         ,o."OGA PROJECT NUMBER"
         ,o."OGA AWARD NUMBER"
         ,o."AGENCY AWARD NUMBER"
         ,i.rowId
         ,o."PI FULL NAME"
         ,f.rowid
         ,'0F8BB08E-E4BF-102F-B89B-5107380A5B61'
         ,1003
         ,now()
         ,'OGA'
         ,o.faRate
         ,o."BURDEN SCHEDULE"
         ,o."CURRENT BUDGET START DATE"
         ,o."CURRENT BUDGET END DATE"
         ,o."PROJECT TITLE"
         ,o."PROJECT DESCRIPTION"
         ,o."PROJECT STATUS"
         ,o."OGA AWARD TYPE"
         ,'ENTERED BY ISE'
         ,o."PPQ CODE"
         ,o."PPQ DATE"
         ,o."AWARD STATUS"
         ,o."AWARD ID"::varchar
         ,o."APPLICATION TYPE"::varchar
         ,o."PROJECT ID"::varchar
         ,o."OGA AWARD TYPE"
         ,o."AWARD NUMBER"
         ,o."AWARD SUFFIX"
         ,o."ADFM EMP NUM"::varchar
         ,o."ADFM FULL NAME"
         ,o."ORG"
         ,o.ORIGINATING_AGENCY_AWARD_NUM
    FROM onprc_billing.ogasynch o
        LEFT OUTER JOIN onprc_ehr.investigators i ON o."PI EMP NUM"::varchar = i.employeeid AND i.datedisabled IS NULL
        LEFT OUTER JOIN onprc_billing.fiscalAuthorities f ON f.employeeId = o."PDFM EMP NUM"::varchar AND f.active IS TRUE;

    RETURN 0;
END;
$$;

/*
** Ported from onprc_billing-20.410-20.411.sql. One-time cleanup of the onprc_billing.aliases dataset,
** written in 2020 with hard-coded dates.
**
** Note: the ogaAliasCleanUp2020 ETL in onprc_ehr declares procedureName="oga_AliasCleanup2020", which
** matches neither this function nor the archived oga_AliasCleanup. That mismatch predates this migration
** and is equally broken on SQL Server; it is not fixed here.
**
** The SQL Server version joined projectAccountHistory and ogaSynch in two of the updates without
** referencing either in the SET or WHERE clauses. Those dead joins are dropped rather than translated.
*/
CREATE OR REPLACE FUNCTION onprc_billing.AliasCleanup202004()
RETURNS integer
LANGUAGE plpgsql
AS $$
BEGIN
    -- Handles active non-OGA aliases
    UPDATE onprc_billing.aliases a
    SET projectStatus = 'Active', comments = 'In Use - Non ONPRC Alias', category = 'OHSU GL'
    FROM onprc_billing.projectAccountHistory p
    WHERE p.account = a.alias
      AND p.enddate >= now()
      AND a.alias NOT LIKE '9%';

    -- Sets end date and comment for disabled aliases
    UPDATE onprc_billing.aliases
    SET dateDisabled = TIMESTAMP '2020-04-01', COMMENTS = 'Alias Disabled'
    WHERE lower(aliasEnabled) = lower('N');

    UPDATE onprc_billing.aliases
    SET projectStatus = 'Non Active GL', aliasEnabled = 'n', dateDisabled = now(), comments = 'GL Alias Not Active entered Previously'
    WHERE alias NOT LIKE '9%'
      AND (lower(comments) != lower('In Use - Non ONPRC Alias') OR comments IS NULL);

    -- Handles expired aliases
    UPDATE onprc_billing.aliases
    SET dateDisabled = now(), comments = 'Expired Alias', aliasEnabled = 'n'
    WHERE budgetEndDate <= now();

    UPDATE onprc_billing.aliases
    SET dateDisabled = now(), comments = 'Grant Closed', projectStatus = 'Grant Closed', aliasEnabled = 'N'
    WHERE dateDisabled IS NULL
      AND lower(projectStatus) IN (lower('Archived'), lower('Closed'), lower('IM PURGEd'));

    -- Remove records not associated with ONPRC
    DELETE FROM onprc_billing.aliases
    WHERE alias IN (SELECT a.alias
                    FROM onprc_billing.aliases a
                        LEFT OUTER JOIN onprc_billing.projectAccountHistory p ON a.alias = p.account
                    WHERE p.account IS NULL AND a.dateDisabled IS NOT NULL);

    RETURN 0;
END;
$$;

/*
** clinPathRunDateFinalized ETL (declared in onprc_ehr). Ported from onprc_billing-23.002-23.003.sql.
** Updates the end date for ClinPath runs that are complete but have no dateFinalized.
**
** studydataset.c6d199_clinpathruns is a provisioned dataset table, so it may not exist when this
** function is created; plpgsql resolves table references at execution time, so that is fine. The table
** alias is required because "date" is both a column name here and a type name to the parser.
*/
CREATE OR REPLACE FUNCTION onprc_billing.UpdateClinPathEndDate()
RETURNS integer
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE studydataset.c6d199_clinpathruns t
    SET datefinalized = t.date
    WHERE t.datefinalized IS NULL
      AND t.date > TIMESTAMP '2023-05-01'
      AND t.qcstate = 18;

    RETURN 0;
END;
$$;
