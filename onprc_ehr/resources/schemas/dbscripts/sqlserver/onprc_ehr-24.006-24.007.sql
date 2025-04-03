-- =======================================================================================================================================
-- Author:		Lakshmi Kolli
-- Create date: 2025-03-04
-- Description:	Db tables creation for Prima cassette project. Created all the Prima tables in Prime onprc_ehr schema folder. Tkt #
-- =======================================================================================================================================

--Drop if exists...
EXEC core.fn_dropifexists 'Prima_Animals','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_VeterinaryResearchCase','onprc_ehr','TABLE'; --Drop this table permanently
EXEC core.fn_dropifexists 'Prima_TissueCollections','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CaseBase','onprc_ehr','TABLE';

GO

--Create tables
--1. Animals table
/****** Object:  Table [onprc_ehr].[Prima_Animals]  ******/
CREATE TABLE [onprc_ehr].[Prima_Animals](
    [Id] [int] IDENTITY(1,1) NOT NULL,
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
    [Id] [int] IDENTITY(1,1) NOT NULL,
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
    [AlternateIdentifier] [nvarchar](24) NULL,
    [SurgeryLocationId] [int] NULL,
    [ResearchPatientId] [int] NULL,
    [AnimalId] [int] NULL,
    [ClinicalPatientId] [int] NULL,
    [SurgeryAge] [nvarchar](31) NULL
    )
;

GO