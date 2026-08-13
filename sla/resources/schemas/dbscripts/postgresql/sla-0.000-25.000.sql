/*
 * Copyright (c) 2011 LabKey Corporation
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

-- Create schema, tables, indexes, and constraints used for SLA module here
-- All SQL VIEW definitions should be created in sla-create.sql and dropped in sla-drop.sql
CREATE SCHEMA sla;

CREATE TABLE sla.census
(
    RowID SERIAL NOT NULL,
    Project INTEGER,
    CountDate TIMESTAMP,
    InvestigatorId INTEGER,
    Room VARCHAR(255),
    Species VARCHAR(255),
    CageType VARCHAR(255),
    CageSize VARCHAR(255),
    CountType INTEGER,
    AnimalCount INTEGER,
    CageCount INTEGER,
    DLAMInventory INTEGER,
    objectid ENTITYID,

    Container ENTITYID NOT NULL,
    CreatedBy USERID,
    Created TIMESTAMP,
    ModifiedBy USERID,
    Modified TIMESTAMP,

    CONSTRAINT PK_census PRIMARY KEY (rowId)
);

CREATE TABLE sla.etl_runs
(
    RowId SERIAL,
    date TIMESTAMP,
    queryname VARCHAR(200),
    rowversion VARCHAR(200),

    Container ENTITYID NOT NULL,

    CONSTRAINT PK_etl_runs PRIMARY KEY (rowId)
);

CREATE TABLE sla.purchase(
    RowID SERIAL NOT NULL,
    Project INTEGER,
    UserID INTEGER,
    PriInvPhone VARCHAR(255),
    PriInvEmail VARCHAR(255),
    RequestorID INTEGER,
    VendorID INTEGER,
    Username VARCHAR(255),
    OHSUAlias VARCHAR(255),
    HazardousAgentsUsed INTEGER,
    HazardsList VARCHAR(255),
    DOBRequired INTEGER,
    AdditionalVendorInfo VARCHAR(255),
    OtherVendor VARCHAR(255),
    VendorContact VARCHAR(255),
    ConfirmationNum VARCHAR(255),
    HousingConfirmed INTEGER,
    IACUCConfirmed INTEGER,
    RequestDate TIMESTAMP,
    OrderDate TIMESTAMP,
    AdminComments VARCHAR(500),
    DARComments VARCHAR(500),
    OrderedBy VARCHAR(255),
    ProjFundingSource VARCHAR(255),
    objectid ENTITYID,

    Container ENTITYID,
    CreatedBy USERID,
    Created TIMESTAMP,
    ModifiedBy USERID,
    Modified TIMESTAMP,

    CONSTRAINT PK_purchase PRIMARY KEY (rowId)
);

CREATE TABLE sla.purchaseDetails(
    RowId SERIAL NOT NULL,
    PurchaseID INTEGER,
    Species INTEGER,
    Age VARCHAR(255),
    Weight VARCHAR(255),
    Gestation VARCHAR(255),
    Sex INTEGER,
    Strain VARCHAR(255),
    CageID INTEGER,
    NumAnimalsOrdered INTEGER,
    NumAnimalsReceived INTEGER,
    BoxesQuantity INTEGER,
    CostPerAnimal VARCHAR(255),
    ShippingCost VARCHAR(255),
    TotalCost VARCHAR(255),
    HousingInstructions VARCHAR(255),
    RequestedArrivalDate TIMESTAMP,
    ExpectedArrivalDate TIMESTAMP,
    ReceivedDate TIMESTAMP,
    ReceivedBy VARCHAR(255),
    CancelledBy VARCHAR(255),
    DateCancelled TIMESTAMP,
    objectid ENTITYID,

    Container ENTITYID,
    CreatedBy USERID,
    Created TIMESTAMP,
    ModifiedBy USERID,
    Modified TIMESTAMP,

    CONSTRAINT PK_purchaseDetails PRIMARY KEY (rowId)
);

CREATE TABLE sla.requestors(
    RowId SERIAL NOT NULL,
    RequestorId INTEGER,
    LastName VARCHAR(255),
    FirstName VARCHAR(255),
    Initials VARCHAR(10),
    PhoneNumber VARCHAR(20),
    EmailAddress VARCHAR(255),
    objectid ENTITYID,

    Container ENTITYID,
    CreatedBy USERID,
    Created TIMESTAMP,
    ModifiedBy USERID,
    Modified TIMESTAMP,

    CONSTRAINT PK_requestors PRIMARY KEY (rowId)
);

CREATE TABLE sla.vendors(
    RowId SERIAL NOT NULL,
    SLAVendorName VARCHAR(255),
    Phone1 VARCHAR(15),
    Phone2 VARCHAR(15),
    FundingSourceRequired INTEGER,
    Comments VARCHAR(255),
    objectid ENTITYID,

    Container ENTITYID,
    CreatedBy USERID,
    Created TIMESTAMP,
    ModifiedBy USERID,
    Modified TIMESTAMP,

    CONSTRAINT PK_vendors PRIMARY KEY (rowId)
);

CREATE TABLE sla.emailList(
    RowId SERIAL NOT NULL,
    Name VARCHAR(100),
    Email VARCHAR(100),
    PrimaryNotifier INTEGER,
    objectid ENTITYID,

    Container ENTITYID,
    CreatedBy USERID,
    Created TIMESTAMP,
    ModifiedBy USERID,
    Modified TIMESTAMP,

    CONSTRAINT PK_emailList PRIMARY KEY (rowId)
);

/* 13.xxx SQL scripts */

--it is easier to drop/recreate, rather than try incremental changes:
SELECT core.fn_dropifexists('census', 'sla', 'TABLE', NULL);
SELECT core.fn_dropifexists('etl_runs', 'sla', 'TABLE', NULL);
SELECT core.fn_dropifexists('purchase', 'sla', 'TABLE', NULL);
SELECT core.fn_dropifexists('purchaseDetails', 'sla', 'TABLE', NULL);
SELECT core.fn_dropifexists('requestors', 'sla', 'TABLE', NULL);
SELECT core.fn_dropifexists('vendors', 'sla', 'TABLE', NULL);
SELECT core.fn_dropifexists('emailList', 'sla', 'TABLE', NULL);

SELECT core.fn_dropifexists('*', 'sla', 'schema', NULL);

CREATE SCHEMA sla;

CREATE TABLE sla.census (
    rowid SERIAL NOT NULL,
    project INTEGER,
    date TIMESTAMP,
    investigatorid ENTITYID,  --onprc_ehr.investigators
    room VARCHAR(255),
    species VARCHAR(255),
    cagetype VARCHAR(255),
    cagesize VARCHAR(255),
    counttype INTEGER,
    animalcount INTEGER,
    cagecount INTEGER,
    dlaminventory INTEGER,
    objectid ENTITYID,

    container ENTITYID NOT NULL,
    createdby USERID,
    created TIMESTAMP,
    modifiedby USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_census PRIMARY KEY (rowid)
);

CREATE TABLE sla.etl_runs (
    rowid SERIAL,
    date TIMESTAMP,
    queryname VARCHAR(200),
    rowversion VARCHAR(200),

    container ENTITYID NOT NULL,

    CONSTRAINT PK_etl_runs PRIMARY KEY (rowid)
);

CREATE TABLE sla.purchase (
    rowid SERIAL NOT NULL, --not the PK
    project INTEGER,
    account VARCHAR(255),
    requestorid ENTITYID,
    vendorid ENTITYID,

    hazardslist VARCHAR(255),
    dobrequired INTEGER,
    comments VARCHAR(4000),
    confirmationnum VARCHAR(255),
    housingconfirmed INTEGER,
    iacucconfirmed INTEGER,
    requestdate TIMESTAMP,
    orderdate TIMESTAMP,
    orderedby VARCHAR(100),
    objectid ENTITYID,

    container ENTITYID,
    createdby USERID,
    created TIMESTAMP,
    modifiedby USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_purchase PRIMARY KEY (objectid)
);

CREATE TABLE sla.purchaseDetails (
    rowid SERIAL NOT NULL,
    purchaseid ENTITYID,
    species INTEGER,
    age DOUBLE PRECISION,
    weight DOUBLE PRECISION,
    weight_units VARCHAR(100),
    gestation VARCHAR(255),
    gender VARCHAR(100),
    strain VARCHAR(255),
    cageid INTEGER,
    animalsordered INTEGER,
    animalsreceived INTEGER,
    boxesquantity INTEGER,
    costperanimal VARCHAR(255),
    shippingcost VARCHAR(255),
    totalcost VARCHAR(255),
    housingInstructions VARCHAR(255),
    requestedarrivaldate TIMESTAMP,
    expectedarrivaldate TIMESTAMP,
    receiveddate TIMESTAMP,
    receivedby VARCHAR(255),
    cancelledby VARCHAR(255),
    datecancelled TIMESTAMP,
    objectid ENTITYID,

    container ENTITYID,
    createdby USERID,
    created TIMESTAMP,
    modifiedby USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_purchaseDetails PRIMARY KEY (objectid)
);

CREATE TABLE sla.requestors (
    rowid SERIAL NOT NULL,  --not the PK
    lastname VARCHAR(255),
    firstname VARCHAR(255),
    initials VARCHAR(10),
    phone VARCHAR(20),
    email VARCHAR(255),
    userid USERID,
    objectid ENTITYID NOT NULL,

    container ENTITYID,
    createdby USERID,
    created TIMESTAMP,
    modifiedby USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_requestors PRIMARY KEY (objectid)
);

CREATE TABLE sla.vendors (
    rowid SERIAL NOT NULL, --not the PK
    name VARCHAR(255),
    phone1 VARCHAR(15),
    phone2 VARCHAR(15),
    fundingSourceRequired INTEGER,
    comments VARCHAR(255),
    objectid ENTITYID NOT NULL,

    container ENTITYID,
    createdby USERID,
    created TIMESTAMP,
    modifiedby USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_vendors PRIMARY KEY (objectid)
);

ALTER TABLE sla.census DROP CONSTRAINT PK_census;
ALTER TABLE sla.census ALTER COLUMN objectid SET NOT NULL;
ALTER TABLE sla.census DROP COLUMN rowid;

ALTER TABLE sla.census ADD CONSTRAINT PK_census PRIMARY KEY (objectid);

CREATE TABLE sla.allowableAnimals (
    protocol VARCHAR(4000),
    species VARCHAR(200),
    strain VARCHAR(200),
    gender VARCHAR(100),
    age VARCHAR(100),
    allowed INTEGER,

    startdate TIMESTAMP,
    enddate TIMESTAMP,

    objectid ENTITYID NOT NULL,
    container ENTITYID NOT NULL,
    createdby INTEGER NOT NULL,
    created TIMESTAMP NOT NULL,
    modifiedby INTEGER NOT NULL,
    modified TIMESTAMP NOT NULL,

    CONSTRAINT PK_allowableAnimals PRIMARY KEY (objectid)
);

CREATE TABLE sla.species (
    species VARCHAR(200),

    datedisabled TIMESTAMP,
    createdby INTEGER,
    created TIMESTAMP,
    modifiedby INTEGER,
    modified TIMESTAMP,

    CONSTRAINT PK_species PRIMARY KEY (species)
);

INSERT INTO sla.species (species) VALUES ('Rats');
INSERT INTO sla.species (species) VALUES ('Hamsters');
INSERT INTO sla.species (species) VALUES ('Guinea Pigs');
INSERT INTO sla.species (species) VALUES ('Mice');
INSERT INTO sla.species (species) VALUES ('Rabbits');
INSERT INTO sla.species (species) VALUES ('Frogs');
INSERT INTO sla.species (species) VALUES ('Birds');
INSERT INTO sla.species (species) VALUES ('Fish');

CREATE TABLE sla.gender (
    gender VARCHAR(200),

    datedisabled TIMESTAMP,
    createdby INTEGER,
    created TIMESTAMP,
    modifiedby INTEGER,
    modified TIMESTAMP,

    CONSTRAINT PK_gender PRIMARY KEY (gender)
);

INSERT INTO sla.gender (gender) VALUES ('Male or Female');
INSERT INTO sla.gender (gender) VALUES ('Female');
INSERT INTO sla.gender (gender) VALUES ('Male');

ALTER TABLE sla.census ADD taskid ENTITYID;
ALTER TABLE sla.census ADD formSort INTEGER;

ALTER TABLE sla.census ADD QCState INTEGER;

-- Adding placeholder protocols table for use in the SLA prototype
-- I expect that this table will have additional columns related to the IACUC protocols.
CREATE TABLE sla.protocols (
    protocol VARCHAR(4000),
    account VARCHAR(255),
    "grant" VARCHAR(255),
    --additional IACUC realted fields expected

    --TODO are the protocols container specific?
    --container entityid not null,

    createdby INTEGER NOT NULL,
    created TIMESTAMP NOT NULL,
    modifiedby INTEGER NOT NULL,
    modified TIMESTAMP NOT NULL,

    CONSTRAINT PK_protocols PRIMARY KEY (protocol)
);

CREATE TABLE sla.Reference_Data (
    rowId SERIAL,
    label VARCHAR(250) DEFAULT NULL,
    value VARCHAR(255),
    columnName VARCHAR(255) NOT NULL,
    sort_order INTEGER NULL,
    endDate TIMESTAMP DEFAULT NULL,

    CONSTRAINT pk_reference PRIMARY KEY (value)
);

CREATE TABLE sla.purchaseDrafts (
    rowid SERIAL NOT NULL,
    owner USERID NOT NULL,
    content TEXT NOT NULL,

    container ENTITYID NOT NULL,
    createdby USERID,
    created TIMESTAMP,
    modifiedby USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_purchaseDrafts PRIMARY KEY (rowid)
);

DROP TABLE sla.purchaseDetails;

CREATE TABLE sla.purchaseDetails (
    rowid SERIAL NOT NULL,
    purchaseid ENTITYID,
    species VARCHAR(50),
    age VARCHAR(200),
    weight VARCHAR(200),
    weight_units VARCHAR(100),
    gestation VARCHAR(255),
    gender VARCHAR(50),
    strain VARCHAR(255),
    room VARCHAR(255),
    animalsordered INTEGER,
    animalsreceived INTEGER,
    boxesquantity INTEGER,
    costperanimal VARCHAR(255),
    shippingcost VARCHAR(255),
    totalcost VARCHAR(255),
    housingInstructions VARCHAR(255),
    requestedarrivaldate TIMESTAMP,
    expectedarrivaldate TIMESTAMP,
    receiveddate TIMESTAMP,
    receivedby VARCHAR(255),
    cancelledby VARCHAR(255),
    datecancelled TIMESTAMP,
    objectid ENTITYID,

    container ENTITYID,
    createdby USERID,
    created TIMESTAMP,
    modifiedby USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_purchaseDetails PRIMARY KEY (objectid)
);

ALTER TABLE sla.purchase ADD DARComments VARCHAR(1000);
ALTER TABLE sla.purchase ADD VendorContact VARCHAR(100);

ALTER TABLE sla.purchaseDetails ADD sla_DOB TIMESTAMP;
ALTER TABLE sla.purchaseDetails ADD vendorLocation VARCHAR(200);

/* 23.xxx SQL scripts */

SELECT core.fn_dropifexists('protocols', 'sla', 'TABLE', NULL);

-- =================================================================================================
--Created by Kollil
--These tables and stored proc was created to enter weaning data into SLA tables
--Refer to ticket #11233
-- =================================================================================================

--Drop table if exists
SELECT core.fn_dropifexists('weaning', 'sla', 'TABLE', NULL);
--Drop Stored proc if exists
SELECT core.fn_dropifexists('SLAWeaningDataTransfer', 'onprc_ehr', 'PROCEDURE', NULL);

CREATE TABLE sla.weaning (
    rowid SERIAL NOT NULL,
    investigator VARCHAR(250),
    date TIMESTAMP,  -- Pup's DOB
    project VARCHAR(200),
    vendorLocation VARCHAR(200),
    DOB TIMESTAMP,   --Dam's DOB
    DOM TIMESTAMP,   --Date of Mating
    species VARCHAR(100),
    sex VARCHAR(100),
    strain VARCHAR(200),
    numAlive INTEGER,
    numDead INTEGER,
    totalPups INTEGER,
    dateofTransfer TIMESTAMP,    --The date of transfer into SLA tables
    createdBy USERID,
    created TIMESTAMP,
    modifiedBy USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_weaning PRIMARY KEY (rowid)
);

/****** Object:  StoredProcedure  sla.SLAWeaningDataTransfer   Script Date: 8/24/2024 *****/
-- ==========================================================================================
-- Author: Lakshmi Kolli
-- Create date: 8/24/2024
-- Description: Create a stored proc to check for any rodents with age >= 21 days and enter
-- the data into SLA tables
-- ==========================================================================================

CREATE OR REPLACE PROCEDURE onprc_ehr.SLAWeaningDataTransfer()
LANGUAGE plpgsql
AS $$
DECLARE
    _WCount                 INTEGER;
    _alias                  VARCHAR(100);
    _purchaseId             ENTITYID;
    _center_project         INTEGER;
    _center_project2        INTEGER;
    _counter                INTEGER;
    _counter2               INTEGER;
    _DOT                    TIMESTAMP;
    _DOT2                   TIMESTAMP;
    _max_rowid              INTEGER;
BEGIN
    --Check if any rodents age is 21 days and above and not transferred into SLA tables
    SELECT COUNT(*) INTO _WCount
    FROM sla.weaning
    WHERE numAlive > 0
      AND dateofTransfer IS NULL
      AND (CURRENT_DATE - CAST(date AS DATE)) >= 21;

    --Found entries, so, insert those records into SLA.purchase and SLA.purchasedetails tables
    IF _WCount > 0 THEN
        --Create a local temp table to process the weaning data.
        CREATE TEMP TABLE TempWeaning (
            rowid SERIAL NOT NULL,
            orig_weaning_rowid INTEGER,
            investigator VARCHAR(250),
            date TIMESTAMP,
            project VARCHAR(200),
            vendorLocation VARCHAR(200),
            DOB TIMESTAMP,
            DOM TIMESTAMP,
            species VARCHAR(100),
            sex VARCHAR(100),
            strain VARCHAR(200),
            numAlive INTEGER,
            dateofTransfer TIMESTAMP,
            created TIMESTAMP
        ) ON COMMIT DROP;

        --Move the weaning entries into a temp table
        INSERT INTO TempWeaning (orig_weaning_rowid, investigator, date, project, vendorlocation, DOB, DOM, species, sex, strain, numAlive, created)
        SELECT rowid, investigator, date, project, vendorlocation, date, DOM, species,
            CASE
                WHEN sex = 'F' THEN 'Female'
                WHEN sex = 'M' THEN 'Male'
                ELSE 'Male or Female'
            END AS sex,
            strain, numAlive, now()
        FROM sla.weaning
        WHERE numAlive > 0
          AND dateofTransfer IS NULL
          AND (CURRENT_DATE - CAST(date AS DATE)) >= 21;

        --Set the counter seed value and upper bound
        SELECT MIN(rowid), MAX(rowid) INTO _counter, _max_rowid FROM TempWeaning;

        WHILE _counter <= _max_rowid
        LOOP
            /* Requestorid - (Kati Marshall ) - 7B3F1ED1-4CD9-4D9A-AFF4-FE0618D49C4B
            Userid - (Kati Marshall) - 1294
            vendor - (ONPRC Weaning - SLA) - E1EE1B64-B7BE-1035-BFC4-5107380AE41E
            container - (SLA) - 4831D09C-4169-1034-BAD2-5107380A9819
            created - (onprc-is) - 1003
            */

            SELECT dateofTransfer INTO _DOT FROM TempWeaning WHERE rowid = _counter;
            IF _DOT IS NULL THEN
                -- Get projectid, PI and account
                SELECT project, account INTO _center_project, _alias
                FROM ehr.project
                WHERE name = (SELECT project FROM TempWeaning WHERE rowid = _counter);

                _purchaseId := core.fn_calculate_entityid();

                -- Check if the row is already transferred into the main SLA tables. If DOT is null means the row hasn't been transferred yet.
                -- Insert weaning data into sla.purchase table as a pending order
                INSERT INTO sla.purchase
                (project, account, requestorid, vendorid, hazardslist, dobrequired, comments, confirmationnum, housingconfirmed,
                 iacucconfirmed, requestdate, orderdate, orderedby, objectid, container, createdby, created, modifiedby, modified, DARComments, VendorContact)
                VALUES
                (_center_project, _alias, '7B3F1ED1-4CD9-4D9A-AFF4-FE0618D49C4B', 'E1EE1B64-B7BE-1035-BFC4-5107380AE41E', '', 0, '', NULL, NULL, NULL, NULL, NULL, '', _purchaseId,
                '4831D09C-4169-1034-BAD2-5107380A9819', 1003, now(), NULL, NULL, '', '');

                --Insert data into purchasedetails with the newly created purchaseid above
                INSERT INTO sla.purchaseDetails
                (purchaseid, species, age, weight, weight_units, gestation, gender, strain, room, animalsordered, animalsreceived, boxesquantity, costperanimal, shippingcost,
                 totalcost, housingInstructions, requestedarrivaldate, expectedarrivaldate, receiveddate, receivedby, cancelledby, datecancelled,
                 objectid, container, createdby, created, modifiedby, modified, sla_DOB, vendorLocation)
                SELECT _purchaseId, species, CAST((CURRENT_DATE - CAST(date AS DATE)) AS VARCHAR) || ' days', '', '', '', sex, strain, '', numAlive, NULL, NULL, '', '',
                '', '', date + INTERVAL '21 days', date + INTERVAL '21 days', NULL, '', '', NULL,
                core.fn_calculate_entityid(), '4831D09C-4169-1034-BAD2-5107380A9819', 1003, now(), NULL, NULL, date, vendorLocation
                FROM TempWeaning WHERE rowid = _counter;

                --Update the sla.weaning row with the date of transfer date set for the transferred weaning row
                UPDATE sla.weaning
                SET dateofTransfer = now()
                WHERE rowid = (SELECT orig_weaning_rowid FROM TempWeaning WHERE rowid = _counter);

                UPDATE TempWeaning
                SET dateofTransfer = now()
                WHERE rowid = _counter;

                --Find if there are any rows with the same center project. Then create them under the same purchaseId
                --set the new counter
                _counter2 := _counter + 1;
                WHILE _counter2 <= _max_rowid
                LOOP
                    SELECT dateofTransfer INTO _DOT2 FROM TempWeaning WHERE rowid = _counter2;
                    IF _DOT2 IS NULL THEN
                        --Get projectid of the next row
                        SELECT project INTO _center_project2
                        FROM ehr.project
                        WHERE name = (SELECT project FROM TempWeaning WHERE rowid = _counter2);

                        --If they are same projects, then use the the same purchaseid when creating the purchase details record
                        IF (_center_project = _center_project2) THEN
                            INSERT INTO sla.purchaseDetails
                            (purchaseid, species, age, weight, weight_units, gestation, gender, strain, room, animalsordered, animalsreceived, boxesquantity, costperanimal, shippingcost,
                             totalcost, housingInstructions, requestedarrivaldate, expectedarrivaldate, receiveddate, receivedby, cancelledby, datecancelled,
                             objectid, container, createdby, created, modifiedby, modified, sla_DOB, vendorLocation)
                            SELECT _purchaseId, species, CAST((CURRENT_DATE - CAST(date AS DATE)) AS VARCHAR) || ' days', '', '', '', sex, strain, '', numAlive, NULL, NULL, '', '',
                            '', '', date + INTERVAL '21 days', date + INTERVAL '21 days', NULL, '', '', NULL,
                            core.fn_calculate_entityid(), '4831D09C-4169-1034-BAD2-5107380A9819', 1003, now(), NULL, NULL, date, vendorLocation
                            FROM TempWeaning WHERE rowid = _counter2;

                            UPDATE sla.weaning
                            SET dateofTransfer = now()
                            WHERE rowid = (SELECT orig_weaning_rowid FROM TempWeaning WHERE rowid = _counter2);

                            UPDATE TempWeaning
                            SET dateofTransfer = now()
                            WHERE rowid = _counter2;
                        END IF;
                    END IF;
                    _counter2 := _counter2 + 1;
                END LOOP;

            END IF;
            _counter := _counter + 1;
        END LOOP;

        DROP TABLE IF EXISTS TempWeaning;
    END IF;
END;
$$;
