
-- =======================================================================================================================================
-- Author:		Lakshmi Kolli
-- Create date: 2021-06-17
-- Description:	Db tables creation for Prima reporting process. Created all the Prima tables in Prime onprc_ehr schema folder.
-- =======================================================================================================================================

--Drop if exists (Labkey syntax)
EXEC core.fn_dropifexists 'Prima_CaseBase','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CassetteEvents','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CassetteEventLocations','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CassetteBases','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_LabstationTypes','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SlideBases','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SlideEvents','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SlideEventLocations','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_StainTests','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SurgicalWheels','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_UserPersons','onprc_ehr','TABLE';

GO

--Create tables
--1. UserPersons table
/****** Object:  Table [onprc_ehr].[Prima_UserPersons]  Script Date: 6/17/2021 3:52:21 PM ******/
CREATE TABLE [onprc_ehr].[Prima_UserPersons](
    [Id] [int] NOT NULL,
    [DateOfBirth] [datetime] NULL,
    [DepartmentName] [nvarchar](127) NULL,
    [FirstName] [nvarchar](31) NULL,
    [Gender] [tinyint] NOT NULL,
    [LastName] [nvarchar](31) NULL,
    [MiddleName] [nvarchar](31) NULL,
    [Prefix] [int] NULL,
    [SSN] [nvarchar](9) NULL,
    [ProfessionalTitles] [nvarchar](127) NULL,
    [DateOfDeath] [datetime] NULL
    )
;

--2. SurgicalWheel table
/****** Object:  Table [onprc_ehr].[Prima_SurgicalWheels]   Script Date: 6/17/2021 3:53:24 PM ******/
CREATE TABLE [onprc_ehr].[Prima_SurgicalWheels](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [Constant] [tinyint] NULL,
    [Description] [nvarchar](255) NULL,
    [IsActive] [bit] NOT NULL,
    [CreatedByUserId] [int] NOT NULL,
    [Deleted] [datetimeoffset](7) NULL,
    [DeletedByUserId] [int] NULL,
    [NextVersionId] [int] NULL,
    [PreviousVersionId] [int] NULL,
    [Title] [nvarchar](5) NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [LastModified] varchar(500) NOT NULL
    )
;

--3. StainTests table
/****** Object:  Table [onprc_ehr].[Prima_StainTests]  Script Date: 6/17/2021 4:03:39 PM ******/
CREATE TABLE [onprc_ehr].[Prima_StainTests](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [Abbreviation] [nvarchar](127) NOT NULL,
    [Constant] [tinyint] NULL,
    [CptCode] [nvarchar](6) NULL,
    [Description] [nvarchar](255) NULL,
    [StainTestCategoryId] [int] NOT NULL,
    [TimeLength] [int] NOT NULL,
    [CreatedByUserId] [int] NOT NULL,
    [Deleted] [datetimeoffset](7) NULL,
    [DeletedByUserId] [int] NULL,
    [NextVersionId] [int] NULL,
    [PreviousVersionId] [int] NULL,
    [Title] [nvarchar](127) NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [LastModified] varchar(500) NOT NULL,
    [IsValidated] [bit] NOT NULL
    )
;

--4. Slidebases table
/****** Object:  Table [onprc_ehr].[Prima_SlideBases]   Script Date: 6/17/2021 4:04:46 PM ******/
CREATE TABLE [onprc_ehr].[Prima_SlideBases](
    [Id] [bigint] IDENTITY(1,1) NOT NULL,
    [HandStain] [bit] NOT NULL,
    [IsCharged] [bit] NOT NULL,
    [StainTestId] [int] NOT NULL,
    [DilutionFactor] [int] NULL,
    [CaseBaseId] [int] NOT NULL,
    [IsRadioActive] [bit] NOT NULL,
    [PriorityLevelId] [int] NOT NULL,
    [QcStatus] [tinyint] NOT NULL,
    [SurgicalSerialPart] [smallint] NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [OrderedStatus] [tinyint] NOT NULL,
    [SavedIdentifier] [nvarchar](24) NULL,
    [BarcodeContent] [nvarchar](72) NULL,
    [CurrentBatchId] [int] NULL,
    [AlternateIdentifier] [nvarchar](63) NULL,
    [PrintStatus] [tinyint] NOT NULL,
    [ItemStatus] [smallint] NOT NULL,
    [FreeTextNotes] [nvarchar](4000) NULL
    )
;

--5. CaseBase table
/****** Object:  Table [onprc_ehr].[Prima_CaseBase]  Script Date: 6/17/2021 4:07:39 PM ******/
CREATE TABLE [onprc_ehr].[Prima_CaseBase](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [DifferentialDiagnosisId] [int] NULL,
    [PathologistId] [int] NULL,
    [PriorityLevelId] [int] NOT NULL,
    [ResidentPathologistId] [int] NULL,
    [SerialNumber] [int] NOT NULL,
    [SurgeryDate] [datetime] NULL,
    [SurgicalWheelId] [int] NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [ResearcherId] [int] NULL,
    [StudyId] [int] NULL,
    [Discriminator] [nvarchar](128) NULL,
    [StudyPhaseId] [int] NULL,
    [CohortId] [int] NULL,
    [SavedIdentifier] [nvarchar](max) NULL,
    [Status] [tinyint] NOT NULL,
    [AlternateIdentifier] [nvarchar](24) NULL
    )
;

--6. CassetteEvents table
/****** Object:  Table [onprc_ehr].[Prima_CassetteEvents]  Script Date: 6/17/2021 4:08:57 PM ******/
CREATE TABLE [onprc_ehr].[Prima_CassetteEvents](
    [Id] [bigint] IDENTITY(1,1) NOT NULL,
    [CassetteBaseId] [bigint] NOT NULL,
    [EventType] [tinyint] NOT NULL,
    [Status] [smallint] NOT NULL,
    [Trigger] [tinyint] NOT NULL,
    [UserId] [int] NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [EventAction] [int] NULL,
    [TissueProcessorId] [int] NULL,
    [TissueProcessorProgramId] [int] NULL,
    [Discriminator] [nvarchar](128) NOT NULL,
    [CassetteBatchId] [int] NULL,
    [CassetteOrderId] [bigint] NULL,
    [AutomatedCassetteArchivalMachineId] [int] NULL,
    [DisposalReasonId] [int] NULL,
    [ShipmentId] [int] NULL,
    [IsEstimated] [bit] NULL,
    [PrintCount] [int] NULL,
    [BarcodeContent] [nvarchar](max) NULL
    )
;

--7. CassetteEventLocations table
/****** Object:  Table [onprc_ehr].[Prima_CassetteEventLocations]  Script Date: 6/17/2021 4:09:55 PM ******/
CREATE TABLE [onprc_ehr].[Prima_CassetteEventLocations](
    [CassetteEventId] [bigint] NOT NULL,
    [LabStationTypeId] [int] NOT NULL,
    [LocationId] [int] NOT NULL,
    [WorkstationId] [int] NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [PersonId] [int] NULL
    )
;

--8. CassetteBases table
/****** Object:  Table [onprc_ehr].[Prima_CassetteBases]  Script Date: 6/17/2021 4:10:42 PM ******/
CREATE TABLE [onprc_ehr].[Prima_CassetteBases](
    [Id] [bigint] IDENTITY(1,1) NOT NULL,
    [CassetteColorId] [int] NOT NULL,
    [EmbeddingInstructionId] [int] NOT NULL,
    [EmbeddingNotes] [nvarchar](4000) NULL,
    [HasTissue] [bit] NOT NULL,
    [ProtocolCassetteId] [int] NULL,
    [SpecimenBaseId] [bigint] NOT NULL,
    [TissueCollectionId] [int] NULL,
    [TissueProcessorProgramId] [int] NULL,
    [TissueQuantity] [smallint] NOT NULL,
    [CaseBaseId] [int] NOT NULL,
    [IsRadioActive] [bit] NOT NULL,
    [PriorityLevelId] [int] NOT NULL,
    [QcStatus] [tinyint] NOT NULL,
    [SurgicalSerialPart] [smallint] NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [OrderedStatus] [tinyint] NOT NULL,
    [SavedIdentifier] [nvarchar](24) NULL,
    [BarcodeContent] [nvarchar](72) NULL,
    [CurrentBatchId] [int] NULL,
    [AlternateIdentifier] [nvarchar](63) NULL,
    [PrintStatus] [tinyint] NOT NULL,
    [ItemStatus] [smallint] NOT NULL
    )
;

--9. LabstationTypes table
/****** Object:  Table [onprc_ehr].[Prima_LabstationTypes]  Script Date: 6/17/2021 4:41:00 PM ******/
CREATE TABLE [onprc_ehr].[Prima_LabstationTypes](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [CanProcess] [int] NOT NULL,
    [Constant] [int] NULL,
    [Description] [nvarchar](255) NULL,
    [IsEnabled] [bit] NOT NULL,
    [Order] [int] NOT NULL,
    [Title] [nvarchar](127) NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [LastModified] varchar(500) NOT NULL
    )
;

--10. SlideEvents table
/****** Object:  Table [onprc_ehr].[Prima_SlideEvents]  Script Date: 6/17/2021 4:42:08 PM ******/
CREATE TABLE [onprc_ehr].[Prima_SlideEvents](
    [Id] [bigint] IDENTITY(1,1) NOT NULL,
    [SlideBaseId] [bigint] NOT NULL,
    [EventType] [tinyint] NOT NULL,
    [Status] [smallint] NOT NULL,
    [Trigger] [tinyint] NOT NULL,
    [UserId] [int] NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [EventAction] [int] NULL,
    [CoverSlipperId] [int] NULL,
    [OvenId] [int] NULL,
    [OvenProgramId] [int] NULL,
    [SlideImagerId] [int] NULL,
    [SlideStainerId] [int] NULL,
    [Discriminator] [nvarchar](128) NOT NULL,
    [SlideBatchId] [int] NULL,
    [SlideOrderId] [bigint] NULL,
    [DisposalReasonId] [int] NULL,
    [ShipmentId] [int] NULL,
    [PrintCount] [int] NULL,
    [BarcodeContent] [nvarchar](max) NULL,
    [EquipmentId] [int] NULL,
    [AutomatedSlideArchivalMachineId] [int] NULL
    )
;

--11. SlideEventsLocations table
/****** Object:  Table [onprc].[Prima_SlideEventLocations]  Script Date: 6/17/2021 4:43:57 PM ******/
CREATE TABLE [onprc_ehr].[Prima_SlideEventLocations](
    [SlideEventId] [bigint] NOT NULL,
    [LabStationTypeId] [int] NOT NULL,
    [LocationId] [int] NOT NULL,
    [WorkstationId] [int] NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [PersonId] [int] NULL
    )
;

GO

--Create the stored procedures for the SSRS reports
-- =======================================================================================================================================
-- Author:		Lakshmi Kolli
-- Create date: 2021-06-15
-- Description:	This stored procedure creates the Prima Slide billing report for the specified date range.
--				This proc is used to create the SSRS report.
-- =======================================================================================================================================

Create Procedure [onprc_ehr].[PrimaSlideBillingReport]
    @startDate smalldatetime,
    @endDate smalldatetime

AS

DECLARE
@staining int,
@embedding int,
@complete int

BEGIN
    --SET @startDate = '2000-01-01' -- 00:00:00.0000000 -07:00'
    --SET @endDate = '2021-05-31' -- 00:00:00.0000000 -07:00'
SET @staining = (SELECT id FROM Prima_LabstationTypes WHERE Constant = 10)
SET @embedding = (SELECT id FROM Prima_LabstationTypes WHERE Constant = 7)
SET @complete = 7 SELECT Prima_surgicalwheels.title AS 'Surgical Wheel',
    CASE
    WHEN Prima_userpersons.lastname IS NOT NULL THEN
    Concat(Prima_userpersons.lastname, ', ', Prima_userpersons.firstname, ' ',
    Prima_userpersons.middlename)
    ELSE 'Unassigned Pathologist'
END AS 'Pathologist',
    Prima_staintests.title AS 'Stain Test',
    sub2.slidecount AS 'Slide Count'
    FROM (SELECT surgicalwheelid,
    Prima_slidebases.staintestid,
    Prima_casebase.pathologistid,
    Count(*) AS SlideCount
    FROM (SELECT Min(Prima_slideevents.created) AS VerifyOrBarcodeEventTime,
    slidebaseid
    FROM Prima_slideevents JOIN Prima_SlideEventLocations
    ON Prima_slideeventlocations.SlideEventId = Prima_slideevents.id
    AND Prima_slideeventlocations.LabStationTypeId = @staining WHERE eventtype = @complete
    GROUP BY slidebaseid) sub
    JOIN Prima_slidebases
    ON slidebaseid = Prima_slidebases.id
    JOIN Prima_casebase
    ON Prima_casebase.id = Prima_slidebases.casebaseid WHERE sub.verifyorbarcodeeventtime >= @startDate
    AND sub.verifyorbarcodeeventtime < @endDate
    GROUP BY surgicalwheelid,
    pathologistid,
    staintestid) sub2
    LEFT JOIN Prima_userpersons
    ON Prima_userpersons.id = sub2.pathologistid
    LEFT JOIN Prima_surgicalwheels
    ON Prima_surgicalwheels.id = sub2.surgicalwheelid
    LEFT JOIN Prima_staintests
    ON Prima_staintests.id = sub2.staintestid
    ORDER BY 'Surgical Wheel',
    'Pathologist',
    'Stain Test'
END
;


-- =======================================================================================================================================
-- Author:		Lakshmi Kolli
-- Create date: 2021-06-15
-- Description:	This stored procedure creates the Prima Block billing report for the specified date range.
--				This proc is used to create the SSRS report.
-- =======================================================================================================================================

CREATE Procedure [onprc_ehr].[PrimaBlockBillingReport]
    @startDate smalldatetime,
    @endDate smalldatetime

AS

DECLARE
@staining int,
@embedding int,
@complete int

BEGIN
    --SET @startDate = '2000-01-01' -- 00:00:00.0000000 -07:00'
    --SET @endDate = '2021-05-31' -- 00:00:00.0000000 -07:00'
SET @staining = (SELECT id FROM Prima_LabstationTypes WHERE Constant = 10)
SET @embedding = (SELECT id FROM Prima_LabstationTypes WHERE Constant = 7)
SET @complete = 7

SELECT Prima_surgicalwheels.title AS 'Surgical Wheel',
        CASE
            WHEN Prima_userpersons.lastname IS NOT NULL THEN
                Concat(Prima_userpersons.lastname, ', ', Prima_userpersons.firstname, ' ',
                       Prima_userpersons.middlename)
            ELSE 'Unassigned Pathologist'
            END AS 'Pathologist',
        sub2.cassettecount AS 'Cassette Count'
FROM (SELECT surgicalwheelid,
             Prima_casebase.pathologistid,
             Count(*) AS CassetteCount
      FROM (SELECT Min(Prima_cassetteevents.created) AS VerifyOrBarcodeEventTime,
                   cassettebaseid
            FROM Prima_cassetteevents
                     JOIN Prima_CassetteEventLocations
                          ON Prima_CassetteEventLocations.CassetteEventId = Prima_cassetteevents.id
                              AND Prima_CassetteEventLocations.LabStationTypeId = @embedding WHERE eventtype = @complete
            GROUP BY cassettebaseid) sub
               JOIN Prima_cassettebases
                    ON cassettebaseid = Prima_cassettebases.id
               JOIN Prima_casebase
                    ON Prima_casebase.id = Prima_cassettebases.casebaseid
      WHERE sub.verifyorbarcodeeventtime >= @startDate
        AND sub.verifyorbarcodeeventtime < @endDate
      GROUP BY surgicalwheelid,
               pathologistid) sub2
         LEFT JOIN Prima_userpersons
                   ON Prima_userpersons.id = sub2.pathologistid
         LEFT JOIN Prima_surgicalwheels
                   ON Prima_surgicalwheels.id = sub2.surgicalwheelid
ORDER BY 'Surgical Wheel',
         'Pathologist'
END
;

GO
