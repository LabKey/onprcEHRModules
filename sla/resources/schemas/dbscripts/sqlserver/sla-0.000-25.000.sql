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
GO

CREATE TABLE sla.census
(
    RowID INT IDENTITY(1,1) NOT NULL,
    Project INTEGER,
    CountDate DATETIME,
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
    Created DATETIME,
    ModifiedBy USERID,
    Modified DATETIME,

    CONSTRAINT PK_census PRIMARY KEY (rowId)
);

CREATE TABLE sla.etl_runs
(
    RowId int identity(1,1),
    date datetime,
    queryname varchar(200),
    rowversion varchar(200),

    Container ENTITYID NOT NULL,

    CONSTRAINT PK_etl_runs PRIMARY KEY (rowId)
);

CREATE TABLE sla.purchase(
    RowID INT IDENTITY(1,1)NOT NULL,
    Project INTEGER ,
    UserID INTEGER,
    PriInvPhone VARCHAR(255),
    PriInvEmail VARCHAR(255),
    RequestorID INTEGER,
    VendorID INTEGER ,
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
    RequestDate DATETIME ,
    OrderDate DATETIME,
    AdminComments VARCHAR(500),
    DARComments VARCHAR(500),
    OrderedBy VARCHAR(255),
    ProjFundingSource VARCHAR(255),
    objectid ENTITYID,

    Container ENTITYID ,
    CreatedBy USERID,
    Created DATETIME,
    ModifiedBy USERID,
    Modified DATETIME,

    CONSTRAINT PK_purchase PRIMARY KEY (rowId)

);

CREATE TABLE sla.purchaseDetails(
    RowId INT IDENTITY(1,1)NOT NULL,
    PurchaseID INTEGER ,
    Species INTEGER ,
    Age VARCHAR(255) ,
    Weight VARCHAR(255) ,
    Gestation VARCHAR(255) ,
    Sex INTEGER ,
    Strain VARCHAR(255) ,
    CageID INTEGER ,
    NumAnimalsOrdered INTEGER ,
    NumAnimalsReceived INTEGER ,
    BoxesQuantity INTEGER ,
    CostPerAnimal VARCHAR(255) ,
    ShippingCost VARCHAR(255) ,
    TotalCost VARCHAR(255) ,
    HousingInstructions VARCHAR(255) ,
    RequestedArrivalDate DATETIME ,
    ExpectedArrivalDate DATETIME ,
    ReceivedDate DATETIME ,
    ReceivedBy VARCHAR(255) ,
    CancelledBy VARCHAR(255) ,
    DateCancelled DATETIME ,
    objectid ENTITYID,

    Container ENTITYID ,
    CreatedBy USERID,
    Created DATETIME,
    ModifiedBy USERID,
    Modified DATETIME,

    CONSTRAINT PK_purchaseDetails PRIMARY KEY (rowId)
 );

CREATE TABLE sla.requestors(
	RowId INT IDENTITY(1,1)NOT NULL,
	RequestorId INTEGER,
	LastName VARCHAR(255),
	FirstName VARCHAR(255),
	Initials VARCHAR(10) ,
	PhoneNumber VARCHAR(20),
	EmailAddress VARCHAR(255),
	objectid ENTITYID,

    Container ENTITYID ,
    CreatedBy USERID,
    Created DATETIME,
    ModifiedBy USERID,
    Modified DATETIME,

    CONSTRAINT PK_requestors PRIMARY KEY (rowId)
);

CREATE TABLE sla.vendors(
    RowId INT IDENTITY(1,1)NOT NULL,
    SLAVendorName VARCHAR(255) ,
    Phone1 VARCHAR(15) ,
    Phone2 VARCHAR(15) ,
    FundingSourceRequired INTEGER ,
    Comments VARCHAR(255) ,
    objectid ENTITYID,

    Container ENTITYID ,
    CreatedBy USERID,
    Created DATETIME,
    ModifiedBy USERID,
    Modified DATETIME,

    CONSTRAINT PK_vendors PRIMARY KEY (rowId)

) ;

CREATE TABLE sla.emailList(
    RowId INT IDENTITY(1,1) NOT NULL,
    Name VARCHAR(100) ,
    Email VARCHAR(100) ,
    PrimaryNotifier INTEGER ,
    objectid ENTITYID,

    Container ENTITYID ,
    CreatedBy USERID,
    Created DATETIME,
    ModifiedBy USERID,
    Modified DATETIME,

    CONSTRAINT PK_emailList PRIMARY KEY (rowId)
);

/* 13.xxx SQL scripts */

--it is easier to drop/recreate, rather than try incremental changes:
EXEC core.fn_dropifexists 'census', 'sla', 'TABLE', NULL;
EXEC core.fn_dropifexists 'etl_runs', 'sla', 'TABLE', NULL;
EXEC core.fn_dropifexists 'purchase', 'sla', 'TABLE', NULL;
EXEC core.fn_dropifexists 'purchaseDetails', 'sla', 'TABLE', NULL;
EXEC core.fn_dropifexists 'requestors', 'sla', 'TABLE', NULL;
EXEC core.fn_dropifexists 'vendors', 'sla', 'TABLE', NULL;
EXEC core.fn_dropifexists 'emailList', 'sla', 'TABLE', NULL;

EXEC core.fn_dropifexists '*', 'sla', 'schema', NULL;
GO
CREATE SCHEMA sla;
GO

CREATE TABLE sla.census (
    rowid INT IDENTITY(1,1) NOT NULL,
    project INTEGER,
    date DATETIME,
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
    created DATETIME,
    modifiedby USERID,
    modified DATETIME,

    CONSTRAINT PK_census PRIMARY KEY (rowid)
);

CREATE TABLE sla.etl_runs (
    rowid int identity(1,1),
    date datetime,
    queryname varchar(200),
    rowversion varchar(200),

    container ENTITYID NOT NULL,

    CONSTRAINT PK_etl_runs PRIMARY KEY (rowid)
);

CREATE TABLE sla.purchase (
    rowid INT IDENTITY(1,1) NOT NULL, --not the PK
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
    requestdate DATETIME,
    orderdate DATETIME,
    orderedby VARCHAR(100),
    objectid ENTITYID,

    container ENTITYID,
    createdby USERID,
    created DATETIME,
    modifiedby USERID,
    modified DATETIME,

    CONSTRAINT PK_purchase PRIMARY KEY (objectid)
);

CREATE TABLE sla.purchaseDetails (
    rowid INT IDENTITY(1,1) NOT NULL,
    purchaseid ENTITYID,
    species INTEGER,
    age double precision,
    weight double precision,
    weight_units varchar(100),
    gestation VARCHAR(255),
    gender varchar(100),
    strain VARCHAR(255),
    cageid INTEGER,
    animalsordered INTEGER,
    animalsreceived INTEGER,
    boxesquantity INTEGER,
    costperanimal VARCHAR(255),
    shippingcost VARCHAR(255),
    totalcost VARCHAR(255),
    housingInstructions VARCHAR(255),
    requestedarrivaldate DATETIME,
    expectedarrivaldate DATETIME,
    receiveddate DATETIME,
    receivedby VARCHAR(255),
    cancelledby VARCHAR(255),
    datecancelled DATETIME,
    objectid ENTITYID,

    container ENTITYID,
    createdby USERID,
    created DATETIME,
    modifiedby USERID,
    modified DATETIME,

    CONSTRAINT PK_purchaseDetails PRIMARY KEY (objectid)
 );

CREATE TABLE sla.requestors (
	rowid INT IDENTITY(1,1) NOT NULL,  --not the PK
	lastname VARCHAR(255),
	firstname VARCHAR(255),
	initials VARCHAR(10),
	phone VARCHAR(20),
	email VARCHAR(255),
	userid USERID,
	objectid ENTITYID NOT NULL,

    container ENTITYID,
    createdby USERID,
    created DATETIME,
    modifiedby USERID,
    modified DATETIME,

    CONSTRAINT PK_requestors PRIMARY KEY (objectid)
);

CREATE TABLE sla.vendors (
    rowid INT IDENTITY(1,1) NOT NULL, --not the PK
    name VARCHAR(255),
    phone1 VARCHAR(15),
    phone2 VARCHAR(15),
    fundingSourceRequired INTEGER,
    comments VARCHAR(255),
    objectid ENTITYID NOT NULL,

    container ENTITYID,
    createdby USERID,
    created DATETIME,
    modifiedby USERID,
    modified DATETIME,

    CONSTRAINT PK_vendors PRIMARY KEY (objectid)
);

ALTER TABLE sla.census DROP CONSTRAINT PK_Census;
GO
ALTER TABLE sla.census ALTER COLUMN objectid ENTITYID NOT NULL;
GO
ALTER TABLE sla.census DROP COLUMN rowid;

ALTER TABLE sla.census ADD CONSTRAINT PK_Census PRIMARY KEY (objectid);

CREATE TABLE sla.allowableAnimals (
    protocol varchar(4000),
    species varchar (200),
    strain varchar (200),
    gender varchar(100),
    age varchar(100),
    allowed integer,

    startdate datetime,
    enddate datetime,

    objectid entityid not null,
    container entityid not null,
    createdby integer not null,
    created datetime not null,
    modifiedby integer not null,
    modified datetime not null,

    CONSTRAINT PK_allowableAnimals PRIMARY KEY (objectid)
);

CREATE TABLE sla.species (
    species varchar (200),

    datedisabled datetime,
    createdby integer,
    created datetime,
    modifiedby integer,
    modified datetime,

    CONSTRAINT PK_species PRIMARY KEY (species)
);
GO
INSERT INTO sla.species (species) values ('Rats');
INSERT INTO sla.species (species) values ('Hamsters');
INSERT INTO sla.species (species) values ('Guinea Pigs');
INSERT INTO sla.species (species) values ('Mice');
INSERT INTO sla.species (species) values ('Rabbits');
INSERT INTO sla.species (species) values ('Frogs');
INSERT INTO sla.species (species) values ('Birds');
INSERT INTO sla.species (species) values ('Fish');


CREATE TABLE sla.gender (
    gender varchar (200),

    datedisabled datetime,
    createdby integer,
    created datetime,
    modifiedby integer,
    modified datetime,

    CONSTRAINT PK_gender PRIMARY KEY (gender)
);
GO
INSERT INTO sla.gender (gender) values ('Male or Female');
INSERT INTO sla.gender (gender) values ('Female');
INSERT INTO sla.gender (gender) values ('Male');

ALTER TABLE sla.census add taskid entityid;
ALTER TABLE sla.census add formSort integer;

ALTER TABLE sla.census add QCState Integer;

-- Adding placeholder protocols table for use in the SLA prototype
-- I expect that this table will have additional columns related to the IACUC protocols.
CREATE TABLE sla.protocols (
    protocol varchar(4000),
    account varchar(255),
    "grant" varchar(255),
    --additional IACUC realted fields expected

    --TODO are the protocols container specific?
    --container entityid not null,

    createdby integer not null,
    created datetime not null,
    modifiedby integer not null,
    modified datetime not null,

    CONSTRAINT PK_protocols PRIMARY KEY (protocol)
);

CREATE TABLE sla.Reference_Data (
rowId int identity(1,1),
label varchar(250) DEFAULT NULL,
value varchar(255) ,
columnName varchar(255)  NOT NULL,
sort_order integer  null,
endDate  datetime  DEFAULT NULL,

  CONSTRAINT pk_reference PRIMARY KEY (value)
)
;

GO

CREATE TABLE sla.purchaseDrafts (
    rowid INT IDENTITY(1,1) NOT NULL,
    owner USERID NOT NULL,
    content NVARCHAR(MAX) NOT NULL,

    container ENTITYID NOT NULL,
    createdby USERID,
    created DATETIME,
    modifiedby USERID,
    modified DATETIME,

    CONSTRAINT PK_purchaseDrafts PRIMARY KEY (rowid)
);

DROP TABLE sla.purchaseDetails

CREATE TABLE sla.purchaseDetails (
    rowid INT IDENTITY(1,1) NOT NULL,
    purchaseid ENTITYID,
    species varchar(50),
    age varchar(200),
    weight varchar(200),
    weight_units varchar(100),
    gestation VARCHAR(255),
    gender varchar(50),
    strain VARCHAR(255),
    room varchar(255),
    animalsordered INTEGER,
    animalsreceived INTEGER,
    boxesquantity INTEGER,
    costperanimal VARCHAR(255),
    shippingcost VARCHAR(255),
    totalcost VARCHAR(255),
    housingInstructions VARCHAR(255),
    requestedarrivaldate DATETIME,
    expectedarrivaldate DATETIME,
    receiveddate DATETIME,
    receivedby VARCHAR(255),
    cancelledby VARCHAR(255),
    datecancelled DATETIME,
    objectid ENTITYID,

    container ENTITYID,
    createdby USERID,
    created DATETIME,
    modifiedby USERID,
    modified DATETIME,

    CONSTRAINT PK_purchaseDetails PRIMARY KEY (objectid)
 );

ALTER TABLE sla.purchase add DARComments VARCHAR(1000);
ALTER TABLE sla.purchase add VendorContact VARCHAR(100);

ALTER TABLE sla.purchaseDetails add sla_DOB DATETIME;
ALTER TABLE sla.purchaseDetails add vendorLocation VARCHAR(200);

/* 23.xxx SQL scripts */

EXEC core.fn_dropifexists 'protocols', 'sla', 'TABLE', NULL;
GO

-- =================================================================================================
--Created by Kollil
--These tables and stored proc was created to enter weaning data into SLA tables
--Refer to ticket #11233
-- =================================================================================================

--Drop table if exists
EXEC core.fn_dropifexists 'weaning','sla','TABLE';
--Drop Stored proc if exists
EXEC core.fn_dropifexists 'SLAWeaningDataTransfer', 'onprc_ehr', 'PROCEDURE';
GO

CREATE TABLE sla.weaning (
    rowid int IDENTITY(1,1) NOT NULL,
    investigator varchar(250),
    date DATETIME,  -- Pup's DOB
    project varchar(200),
    vendorLocation varchar(200),
    DOB DATETIME,   --Dam's DOB
    DOM DATETIME,   --Date of Mating
    species varchar(100),
    sex varchar(100),
    strain varchar (200),
    numAlive INTEGER,
    numDead INTEGER,
    totalPups INTEGER,
    dateofTransfer DATETIME,    --The date of transfer into SLA tables
    createdBy USERID,
    created DATETIME,
    modifiedBy USERID,
    modified DATETIME,

    CONSTRAINT PK_weaning PRIMARY KEY (rowid)
);

GO

/****** Object:  StoredProcedure  sla.SLAWeaningDataTransfer   Script Date: 8/24/2024 *****/
-- ==========================================================================================
-- Author: Lakshmi Kolli
-- Create date: 8/24/2024
-- Description: Create a stored proc to check for any rodents with age >= 21 days and enter
-- the data into SLA tables
-- ==========================================================================================

CREATE PROCEDURE [onprc_ehr].[SLAWeaningDataTransfer]
AS

DECLARE
    @WCount			        int,
    @alias			        varchar(100),
    @purchaseId		        entityid,
    @center_project         int,
	@center_project2        int,
    @counter		        int,
	@counter2				int,
	@DOT					DATETIME,
	@DOT2					DATETIME

BEGIN
    --Check if any rodents age is 21 days and above and not transferred into SLA tables
    Select @WCount = COUNT(*) From sla.weaning Where numAlive > 0 And dateofTransfer is null And DateDiff(dd, date, GETDATE()) >= 21

    --Found entries, so, insert those records into SLA.purchase and SLA.purchasedetails tables
    If @WCount > 0 -- start if, 1
    Begin
        --Create a local temp table to process the weaning data. The table drops automatically at the end of the session
        CREATE TABLE #TempWeaning (
          rowid int IDENTITY(1,1) NOT NULL,
          orig_weaning_rowid INTEGER,
          investigator varchar(250),
          date DATETIME,
          project varchar(200),
          vendorLocation varchar(200),
          DOB DATETIME,
          DOM DATETIME,
          species varchar(100),
          sex varchar(100),
          strain varchar (200),
          numAlive INTEGER,
          dateofTransfer DATETIME,
          created DATETIME
        );

        --Move the weaning entries into a temp table
        INSERT INTO #TempWeaning (orig_weaning_rowid, investigator, date, project, vendorlocation, DOB, DOM, species, sex, strain, numAlive, created)
        Select rowid, investigator, date, project, vendorlocation, date, DOM, species,
            CASE
            WHEN sex = 'F' THEN 'Female'
            WHEN sex = 'M' THEN 'Male'
            ELSE 'Male or Female'
        END AS sex,
        strain, numAlive, GETDATE() From sla.weaning Where numAlive > 0 And dateofTransfer is null And DateDiff(dd, date, GETDATE()) >= 21

         --Set the counter seed value
        Select top 1 @counter = rowid from #TempWeaning order by rowid asc

        WHILE @counter <= @WCount -- start 1st while
        BEGIN
            /* Requestorid - (Kati Marshall ) - 7B3F1ED1-4CD9-4D9A-AFF4-FE0618D49C4B
            Userid - (Kati Marshall) - 1294
            vendor - (ONPRC Weaning - SLA) - E1EE1B64-B7BE-1035-BFC4-5107380AE41E
            container - (SLA) - 4831D09C-4169-1034-BAD2-5107380A9819
            created - (onprc-is) - 1003
            */

            Select @DOT = dateofTransfer From #TempWeaning Where rowid = @counter
            If @DOT IS NULL --start @DOT
            Begin
                -- Get projectid, PI and account
                Select @center_project = project, @alias = account From ehr.project Where name = (Select project From #TempWeaning Where rowid = @counter)

                -- Check if the row is already transferred into the main SLA tables. If DOT is null means the row hasn't been transferred yet.
                --Insert weaning data into sla.purchase table as a pending order
                INSERT INTO sla.purchase
                (project, account, requestorid, vendorid, hazardslist, dobrequired, comments, confirmationnum, housingconfirmed,
                 iacucconfirmed, requestdate, orderdate, orderedby, objectid, container, createdby, created, modifiedby, modified, DARComments, VendorContact)
                Select @center_project, @alias ,'7B3F1ED1-4CD9-4D9A-AFF4-FE0618D49C4B','E1EE1B64-B7BE-1035-BFC4-5107380AE41E','',0,'',null,null,null,null,null,'',NEWID(),
                '4831D09C-4169-1034-BAD2-5107380A9819',1003,GETDATE(),null,null,'',''

                --Get the newly created purchaseid from sla.purchase
                Select top 1 @purchaseid = objectid From sla.purchase order by created desc

                --Insert data into purchasedetails with the newly created purchaseid above
                INSERT INTO sla.purchaseDetails
                (purchaseid, species, age, weight, weight_units, gestation, gender, strain, room, animalsordered, animalsreceived, boxesquantity, costperanimal, shippingcost,
                 totalcost, housingInstructions, requestedarrivaldate, expectedarrivaldate, receiveddate, receivedby, cancelledby, datecancelled,
                 objectid, container, createdby, created, modifiedby, modified, sla_DOB, vendorLocation)
                Select @purchaseid, species, CONVERT(VARCHAR, DateDiff(dd, date, GETDATE())) + ' days', '','','',sex, strain,'',numAlive,null,null,'','',
                '','',DateAdd(dd, 21, date), DateAdd(dd, 21, date),null,'','',null,
                NewId(),'4831D09C-4169-1034-BAD2-5107380A9819',1003,GETDATE(),null,null,date,vendorLocation
                From #TempWeaning Where rowid = @counter

                --Update the sla.weaning row with the date of transfer date set for the transferred weaning row
                Update sla.weaning
                Set dateofTransfer = GETDATE() Where rowid = (Select orig_weaning_rowid from #TempWeaning Where rowid = @counter)

                Update #TempWeaning
                Set dateofTransfer = GETDATE() Where rowid = @counter

                --Find if there are any rows with the same center project. Then create them under the same purchaseId
                --set the new counter
                SET @counter2 = @counter + 1;
                WHILE @counter2 <= @Wcount -- start 2nd while
                BEGIN
                    Select @DOT2 = dateofTransfer From #TempWeaning Where rowid = @counter2
                    If @DOT2 IS NULL
                    Begin
                        --Get projectid of the next row
                        Select @center_project2 = project From ehr.project Where name = (Select project From #TempWeaning Where rowid = @counter2)

                        --If they are same projects, then use the the same purchaseid when creating the purchase details record
                        If (@center_project = @center_project2) -- start if, 2
                        Begin
                            INSERT INTO sla.purchaseDetails
                            (purchaseid, species, age, weight, weight_units, gestation, gender, strain, room, animalsordered, animalsreceived, boxesquantity, costperanimal, shippingcost,
                             totalcost, housingInstructions, requestedarrivaldate, expectedarrivaldate, receiveddate, receivedby, cancelledby, datecancelled,
                             objectid, container, createdby, created, modifiedby, modified, sla_DOB, vendorLocation)
                             Select @purchaseid, species, CONVERT(VARCHAR, DateDiff(dd, date, GETDATE())) + ' days', '','','',sex, strain, '',numAlive,null,null,'','',
                             '','',DateAdd(dd, 21, date), DateAdd(dd, 21, date),null,'','',null,
                             NewId(),'4831D09C-4169-1034-BAD2-5107380A9819',1003,GETDATE(),null,null,date,vendorLocation
                            From #TempWeaning Where rowid = @counter2

                            Update sla.weaning
                            Set dateofTransfer = GETDATE() Where rowid = (Select orig_weaning_rowid from #TempWeaning Where rowid = @counter2)

                            Update #TempWeaning
                            Set dateofTransfer = GETDATE() Where rowid = @counter2
                        End -- end if, 2
                    End --end DOT2
                    SET @counter2 = @counter2 + 1;
                END -- end, 2nd while

            End --end @DOT
        SET @counter = @counter + 1;
        END -- end, 1st while
    End -- end if, 1

    --Drop the temp table incase it exists...
    IF EXISTS (SELECT * FROM tempdb.sys.tables WHERE name = '#TempWeaning')
    BEGIN
        DROP TABLE #TempWeaning;
    END;
END
Go