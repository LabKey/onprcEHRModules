



-- Author:	R. Blasa
-- Created: 3-22-2024
-- Description:	Stored procedure program process SciShield INitial Data

CREATE TABLE onprc_ehr_compliancedb.OccHealth_Data
(
    RowId INT IDENTITY(1,1) NOT NULL,
    Email                   nvarchar(500) null,
    [Person Type]           nvarchar(255) null,
    [Employee Status]       nvarchar(100) null,
    [Total Compliance]      nvarchar(100) null,
    [West Campus]           nvarchar(100) null,
    [Hep B]                 nvarchar(100) null,
    [Measles]               nvarchar(100) null,
    [Mumps]                 nvarchar(100) null,
    [Rubella]                nvarchar(100) null,
    [Varicella]              nvarchar(100) null,
    [Tdap]                   nvarchar(100) null,
    [Full Face Respirator]   nvarchar(100) null,
    [Standard Respirator]    nvarchar(100) null,
    [Flu]                    nvarchar(100) null,
    [TB Health Surveillance] nvarchar(100) null,
    [TB Annual]              nvarchar(100) null,
    [TB West Campus]         nvarchar(100) null,
    [AIRC MRI]               nvarchar(100) null,
    [Clinical MRI]           nvarchar(100) null,
    [Supervisor Email]       nvarchar(100) null,
    [Processd]               integer null,
    Container                ENTITYID NOT NULL,
    CreatedBy               USERID,
    Created                 datetime,
    ModifiedBy              USERID,
    Modified                datetime



        CONSTRAINT PK_OccHealth_Data PRIMARY KEY (RowId),

);
GO



CREATE TABLE [onprc_ehr_compliancedb].[OccHealthTemp] (
    [searchID] [int] IDENTITY(100,1) NOT NULL,
    [employeeid] [varchar](500) NULL,
    [requirementname] [varchar](3000) NULL,
    [completeddate] [smalldatetime] NULL,
    [comment] [varchar](300) NULL,
    [createddate] [smalldatetime] NULL,
    [rowid] [int] NULL
    ) ON [PRIMARY]
    GO



CREATE TABLE [onprc_ehr_compliancedb].[OccHealthMasterTemp](
    [searchID] [int] IDENTITY(100,1) NOT NULL,
    [employeeid] [varchar](500) NULL,
    [requirementname] [varchar](3000) NULL,
    [completeddate] [smalldatetime] NULL,
    [comment] [varchar](300) NULL,
    [createddate] [smalldatetime] NULL,
    [rowid] [int] NULL
    ) ON [PRIMARY]
    GO



