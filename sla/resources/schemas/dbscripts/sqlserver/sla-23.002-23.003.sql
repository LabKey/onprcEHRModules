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
    project INTEGER,
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
 investigator varchar(250),
 date DATETIME,
 project INTEGER,
 vendorLocation varchar(200),
 DOB DATETIME,
 DOM DATETIME,
 species varchar(100),
 sex varchar(100),
 strain varchar (200),
 numAlive INTEGER,
 created DATETIME
);

-- Alter the stored proc
/****** Object:  StoredProcedure  onprc_ehr . SLAWeaningDataTransfer   Script Date: 8/24/2024 *****/
-- =================================================================================
-- Author: Lakshmi Kolli
-- Create date: 8/24/2024
-- Description: Create a stored proc to check for any rodents with age of 21 days after the DOB.
-- =================================================================================

CREATE PROCEDURE  sla.SLAWeaningDataTransfer
AS

DECLARE
    @WCount			Int,
    @project		varchar(100),
    @center_project int,
    @PI				varchar(250),
    @investigaorid	int,
    @vendorlocation varchar(250),
    @DOB			smalldatetime,
    @DOM			smalldatetime,
    @strain			varchar(250),
    @sex			varchar(100),
    @species		varchar(100),
    @numAlive		int,
    @numDead		int,
    @totalPups		int,
    @dateofTransfer smalldatetime,
    @alias			varchar(100),
    @purchaseId		entityid,
    @ageindays		int,
    @count			int

BEGIN
    --Check if any rodents that were not recorded in the SLA tables and
    Select @WCount = COUNT(*) From sla.weaning
    Where numAlive > 0 And dateofTransfer is null And DateDiff(dd, GETDATE(), DOB) >= 21

      --Found entries, so, insert those records into SLA.purchase and SLA.purchasedetails tables
    If @WCount > 0
    Begin
        --Delete the rows from temp table before loading new data
        Delete From onprc_ehr.Temp_ClnRemarks

        --Move the weaning entries into a temp table
        INSERT INTO sla.TempWeaning (investigator, date, project, vendorlocation, DOB, DOM, species, sex, strain, numAlive, created)
        Select investigator, date, project, vendorlocation, DOB, DOM, species, sex, strain, numAlive, GETDATE() From sla.weaning
        Where numAlive > 0 And dateofTransfer is null And DateDiff(dd, GETDATE(), DOB) >= 21

        While @count <= @WCount
        Begin
            /* Requestorid - (Kati Marshall ) - 7B3F1ED1-4CD9-4D9A-AFF4-FE0618D49C4B
            Userid - (Kati Marshall) - 1294
            vendor - (ONPRC Weaning - SLA) - E1EE1B64-B7BE-1035-BFC4-5107380AE41E
            Container - (SLA) - 4831D09C-4169-1034-BAD2-5107380A9819
            created - (onprc-is) - 1003
            */
            -- Get projectid , PI and account
            Select @center_project = project, @alias = account From ehr.project Where name = (Select project From sla.TempWeaning Where rowid = @count)

            --Get the age of the rodent
            Select @ageindays = DateDiff(dd, GETDATE(), DOB) From sla.TempWeaning Where rowid = @count

            --Insert weaning data into sla.purchase table as pending order
            INSERT INTO sla.purchase
            (project, account, requestorid, vendorid, hazardslist, dobrequired, comments , confirmationnum , housingconfirmed,
             iacucconfirmed , requestdate , orderdate , orderedby , objectid , container , createdby , created , modifiedby , modified , DARComments , VendorContact )
            Select @center_project, @alias ,'7B3F1ED1-4CD9-4D9A-AFF4-FE0618D49C4B','E1EE1B64-B7BE-1035-BFC4-5107380AE41E','',0,'','',null,null,null,null,'',NEWID(),
            '4831D09C-4169-1034-BAD2-5107380A9819',1294,GETDATE(),null,null,'',''

            --Get the latest purchaseid from sla.purchase
            Select top 1 @purchaseid = objectid From sla.purchase order by created desc

            --Get the specis, sex and strain
            Select @species = species, @sex = sex, @strain = strain From sla.TempWeaning Where rowid = @count

            --Insert data into purchasedetails with the newly created purchaseid above
            INSERT INTO sla.purchaseDetails
            (purchaseid, species ,age,weight ,weight_units,gestation,gender,strain,room ,animalsordered ,animalsreceived,boxesquantity,costperanimal,shippingcost,
            totalcost,housingInstructions ,requestedarrivaldate ,expectedarrivaldate ,receiveddate ,receivedby ,cancelledby ,datecancelled,
            objectid, container, createdby ,created ,modifiedby ,modified ,sla_DOB ,vendorLocation)
            VALUES
            (@purchaseId, @species ,'','','','',@sex, @strain, '',null,null,null,'','',
            '','',null,null,null,'','',null,
            NewId(),'4831D09C-4169-1034-BAD2-5107380A9819',1003,GETDATE(),null,null,null,'')

            SET @count = @count + 1
        End --End while

        --Update the sla.weaning table with the date of transfer date set for the transferred animals
        Update sla.weaning
        Set dateofTransfer = GETDATE() Where numAlive > 0 And dateofTransfer is null And DateDiff(dd, GETDATE(), DOB) >= 21

    End
End

GO