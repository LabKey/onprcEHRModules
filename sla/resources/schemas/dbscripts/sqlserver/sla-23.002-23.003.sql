/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
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