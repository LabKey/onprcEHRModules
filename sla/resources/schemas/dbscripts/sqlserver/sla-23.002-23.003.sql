-- =================================================================================================
--Created by Kollil
--These tables and stored proc was created to enter weaning data into SLA tables
--Refer to ticket #11233
-- =================================================================================================

--Drop table if exists
EXEC core.fn_dropifexists 'weaning','sla','TABLE';
EXEC core.fn_dropifexists 'TempWeaning','sla','TABLE';

--Drop Stored proc if exists
EXEC core.fn_dropifexists 'SLAWeaningDataTransfer', 'sla', 'PROCEDURE';
GO

CREATE TABLE sla.weaning (
    rowid int IDENTITY(1,1) NOT NULL,
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
    numDead INTEGER,
    totalPups INTEGER,
    dateofTransfer DATETIME,
    createdBy USERID,
    created DATETIME,
    modifiedBy USERID,
    modified DATETIME,

    CONSTRAINT PK_weaning PRIMARY KEY (rowid)
);

CREATE TABLE sla.TempWeaning (
     rowid int IDENTITY(1,1) NOT NULL,
     weaning_rowId int NULL,
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
     created DATETIME
);

GO

/****** Object:  StoredProcedure  sla.SLAWeaningDataTransfer   Script Date: 8/24/2024 *****/
-- ==========================================================================================
-- Author: Lakshmi Kolli
-- Create date: 8/24/2024
-- Description: Create a stored proc to check for any rodents with age >= 21 days and enter
-- the data into SLA tables
-- ==========================================================================================

CREATE PROCEDURE  [onprc_ehr].[SLAWeaningDataTransfer]
AS

DECLARE
    @WCount			        Int,
    @project		        varchar(100),
    @center_project         int,
    @PI				        varchar(250),
    @investigaorid	        int,
    @vendorlocation         varchar(250),
    @DOB			        smalldatetime,
    @DOM			        smalldatetime,
    @strain			        varchar(250),
    @sex			        varchar(100),
    @species		        varchar(100),
    @numAlive		        int,
    @numDead		        int,
    @totalPups		        int,
    @dateofTransfer         smalldatetime,
    @alias			        varchar(100),
    @purchaseId		        entityid,
    @ageindays		        int,
    @counter		        int,
	@weaning_rowid	        int,
    @RequestedArrivalDate   smalldatetime,
    @ExpectedArrivalDate    smalldatetime,
    @slaDOB                 smalldatetime,
    @numAnimalsOrdered      int

BEGIN
    --Check if any rodents age is 21 days and above and not transferred into SLA tables
    Select @WCount = COUNT(*) From sla.weaning
    Where numAlive > 0 And dateofTransfer is null And DateDiff(dd, DOB, GETDATE()) >= 21

      --Found entries, so, insert those records into SLA.purchase and SLA.purchasedetails tables
    If @WCount > 0
    Begin
        --Delete the rows from temp table before loading new data
        TRUNCATE TABLE sla.TempWeaning

        --Move the weaning entries into a temp table
        INSERT INTO sla.TempWeaning (weaning_rowid, investigator, date, project, vendorlocation, DOB, DOM, species, sex, strain, numAlive, created)
        Select rowid, investigator, date, project, vendorlocation, DOB, DOM, species,
        CASE
            WHEN sex = 'F' THEN 'Female'
            WHEN sex = 'M' THEN 'Male'
            ELSE 'Male or Female'
        END AS sex,
        strain, numAlive, GETDATE() From sla.weaning
        Where numAlive > 0 And dateofTransfer is null And DateDiff(dd, DOB, GETDATE()) >= 21

            --Set the counter
        Select top 1 @counter = rowid from sla.Tempweaning order by rowid asc

        While @counter <= @WCount
        Begin
            /* Requestorid - (Kati Marshall ) - 7B3F1ED1-4CD9-4D9A-AFF4-FE0618D49C4B
            Userid - (Kati Marshall) - 1294
            vendor - (ONPRC Weaning - SLA) - E1EE1B64-B7BE-1035-BFC4-5107380AE41E
            Container - (SLA) - 4831D09C-4169-1034-BAD2-5107380A9819
            created - (onprc-is) - 1003
            */

            -- Get projectid , PI and account
            Select @center_project = project, @alias = account From ehr.project Where name = (Select project From sla.TempWeaning Where rowid = @counter)

            --Get the age of the rodent and weaning_rowid, species, sex, strain and vendorlocation
            Select @ageindays = DateDiff(dd, DOB, GETDATE()),@weaning_rowid = weaning_rowid,
                   @species = species, @sex = sex, @strain = strain, @vendorlocation = vendorlocation,
                   @RequestedArrivalDate = DateAdd(dd, 21, DOB), @ExpectedArrivalDate = DateAdd(dd, 21, DOB),
                   @slaDOB = DOB, @numAnimalsOrdered = numAlive
            From sla.TempWeaning Where rowid = @counter

            --Insert weaning data into sla.purchase table as a pending order
            INSERT INTO sla.purchase
            (project, account, requestorid, vendorid, hazardslist, dobrequired, comments, confirmationnum, housingconfirmed,
             iacucconfirmed, requestdate, orderdate, orderedby, objectid, container, createdby, created, modifiedby, modified, DARComments, VendorContact)
            Select @center_project, @alias ,'7B3F1ED1-4CD9-4D9A-AFF4-FE0618D49C4B','E1EE1B64-B7BE-1035-BFC4-5107380AE41E','',0,'',null,null,null,null,null,'',NEWID(),
            '4831D09C-4169-1034-BAD2-5107380A9819',1294,GETDATE(),null,null,'',''

            --Get the newly created purchaseid from sla.purchase
            Select top 1 @purchaseid = objectid From sla.purchase order by created desc

            --Insert data into purchasedetails with the newly created purchaseid above
            INSERT INTO sla.purchaseDetails
            (purchaseid, species, age, weight, weight_units, gestation, gender, strain, room, animalsordered, animalsreceived, boxesquantity, costperanimal, shippingcost,
            totalcost, housingInstructions, requestedarrivaldate, expectedarrivaldate, receiveddate, receivedby, cancelledby, datecancelled,
            objectid, container, createdby, created, modifiedby, modified, sla_DOB, vendorLocation)
            VALUES
            (@purchaseId, @species, CONVERT(VARCHAR, @ageindays) + ' days','','','', @sex, @strain, '',@numAnimalsOrdered,null,null,'','',
            '','',@RequestedArrivalDate,@ExpectedArrivalDate,null,'','',null,
            NewId(),'4831D09C-4169-1034-BAD2-5107380A9819',1003,GETDATE(),null,null,@slaDOB,@vendorLocation)

            --Update the sla.weaning row with the date of transfer date set for the transferred weaning row
            Update sla.weaning
            Set dateofTransfer = GETDATE()
            Where rowid = @weaning_rowid

            SET @counter = @counter + 1;

        End --End while
    End
End

Go