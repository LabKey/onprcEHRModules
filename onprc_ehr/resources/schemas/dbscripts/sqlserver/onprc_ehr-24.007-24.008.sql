-- =======================================================================================================================================
-- Author:		Lakshmi Kolli
-- Create date: 2025-03-04
-- Description:	Db tables creation for Prima cassette project. Created all the Prima tables in Prime onprc_ehr schema folder.
-- =======================================================================================================================================

--Drop if exists. We are using these 4 tables for the Cassette Project
EXEC core.fn_dropifexists 'Prima_Animals','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CassetteBases','onprc_ehr','TABLE'; -- Drop this table and create again
EXEC core.fn_dropifexists 'Prima_TissueCollections','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CaseBase','onprc_ehr','TABLE'; -- Drop this table and create again

--Drop these tables permanently. We are not using these tables in onprc_ehr.
EXEC core.fn_dropifexists 'Prima_VeterinaryResearchCase','onprc_ehr','TABLE'; --This table doesn't exist anymore in Prima DB
EXEC core.fn_dropifexists 'Prima_CassetteEvents','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CassetteEventLocations','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_LabstationTypes','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SlideBases','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SlideEvents','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SlideEventLocations','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_StainTests','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SurgicalWheels','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_UserPersons','onprc_ehr','TABLE';

GO

--Create tables
--1. Animals table
/****** Object:  Table [onprc_ehr].[Prima_Animals]  ******/
CREATE TABLE [onprc_ehr].[Prima_Animals](
    [Id] [int] NOT NULL,
    [AlternateIdentifier] [nvarchar](63) NULL,
    [BreedId] [int] NULL,
    [DateOfBirth] [datetime] NULL,
    [FecesId] [int] NULL,
    [Gender] [tinyint] NOT NULL,
    [GeneTarget] [nvarchar](127) NULL,
    [GeneticLine] [nvarchar](127) NULL,
    [Genotype] [nvarchar](127) NULL,
    [Identifier] [nvarchar](127) NULL,
    [MannerOfDeathId] [int] NULL,
    [RoomNumber] [nvarchar](9) NULL,
    [SpeciesId] [int] NOT NULL,
    [StomachContentsId] [int] NULL,
    [StrainId] [int] NULL,
    [DateOfDeath] [datetime] NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [OwnerId] [int] NULL,
    [Perfuse] [bit] NOT NULL,
    [SampleType] [tinyint] NOT NULL
    )
;

--2. TissueCollections table
/****** Object:  Table [onprc_ehr].[Prima_TissueCollections]  ******/
CREATE TABLE [onprc_ehr].[Prima_TissueCollections](
    [Id] [int] NOT NULL,
    [Constant] [tinyint] NULL,
    [IsWholeAnimal] [bit] NOT NULL,
    [SpeciesId] [int] NOT NULL,
    [SpecimenType] [int] NOT NULL,
    [CreatedByUserId] [int] NOT NULL,
    [Deleted] [datetimeoffset](7) NULL,
    [DeletedByUserId] [int] NULL,
    [NextVersionId] [int] NULL,
    [PreviousVersionId] [int] NULL,
    [Title] [nvarchar](127) NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [LastModified] [timestamp] NOT NULL,
    [Abbreviation] [nvarchar](127) NULL
    )
;

--3. CaseBase table
/****** Object:  Table [onprc_ehr].[Prima_CaseBase]  ******/
CREATE TABLE [onprc_ehr].[Prima_CaseBase](
    [Id] [int] NOT NULL,
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
    [AlternateIdentifier] [nvarchar](24) NULL,
    [SurgeryLocationId] [int] NULL,
    [ResearchPatientId] [int] NULL,
    [AnimalId] [int] NULL,
    [ClinicalPatientId] [int] NULL,
    [SurgeryAge] [nvarchar](31) NULL
    )
;

--4. CassetteBases table
/****** Object:  Table [onprc_ehr].[Prima_CassetteBases]  ******/
CREATE TABLE [onprc_ehr].[Prima_CassetteBases](
    [Id] [bigint] NOT NULL,
    [CassetteColorId] [int] NOT NULL,
    [EmbeddingInstructionId] [int] NOT NULL,
    [HasTissue] [bit] NOT NULL,
    [ProtocolCassetteId] [int] NULL,
    [SpecimenBaseId] [bigint] NOT NULL,
    [TissueCollectionId] [int] NULL,
    [TissueProcessorProgramId] [int] NULL,
    [TissueQuantity] [smallint] NOT NULL,
    [CaseBaseId] [int] NOT NULL,
    [PriorityLevelId] [int] NOT NULL,
    [QcStatus] [tinyint] NOT NULL,
    [SurgicalSerialPart] [smallint] NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [OrderedStatus] [tinyint] NOT NULL,
    [SavedIdentifier] [nvarchar](24) NULL,
    [BarcodeContent] [nvarchar](72) NULL,
    [AlternateIdentifier] [nvarchar](63) NULL,
    [PrintStatus] [tinyint] NOT NULL,
    [ItemStatus] [smallint] NOT NULL,
    [Hazard] [tinyint] NOT NULL,
    [CurrentContainerId] [int] NULL
    )
;

GO