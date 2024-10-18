



-- Author:	R. Blasa
-- Created: 3-22-2024
-- Description:	Stored procedure program process SciShield INitial Data

CREATE TABLE onprc_ehr_compliancedb.OccHealth_Data
(
    RowId INT IDENTITY(1,1) NOT NULL,
    Email                    nvarchar(500) null,
    [Person Type]            nvarchar(255) null,
    [Employee Status]        nvarchar(100) null,
    [Total Compliance]       nvarchar(100) null,
    [Hep B]                  nvarchar(100) null,
    [Hep B Date]             datetime null,
    [Measles]                nvarchar(100) null,
    [Measles Date]           datetime null,
    [Mumps]                  nvarchar(100) null,
    [Mumps Date]             datetime null,
    [Rubella]                nvarchar(100) null,
    [Rubella Date]           datetime null,
    [Varicella]              nvarchar(100) null,
    [Varicella Date]         datetime null,
    [Full Face Respirator]   nvarchar(100) null,
    [Full Face Respirator Date] datetime null,
    [Standard Respirator]    nvarchar(100) null,
    [Standard Respirator Date] datetime null,
    [Tdap]                 nvarchar(100) null,
    [Tdap Date]              datetime null,
    [TB West Campus]         nvarchar(100) null,
    [TB West Campus Date]    datetime null,
    [Supervisor Email]       nvarchar(200) null,
    [Processed]              nvarchar(2000) null,
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
    Email                    nvarchar(500) null,
    [Person Type]            nvarchar(255) null,
    [Employee Status]        nvarchar(100) null,
    [Total Compliance]       nvarchar(100) null,
    [Hep B]                  nvarchar(100) null,
    [Hep B Date]             datetime null,
    [Measles]                nvarchar(100) null,
    [Measles Date]           datetime null,
    [Mumps]                  nvarchar(100) null,
    [Mumps Date]             datetime null,
    [Rubella]                nvarchar(100) null,
    [Rubella Date]           datetime null,
    [Varicella]              nvarchar(100) null,
    [Varicella Date]         datetime null,
    [Full Face Respirator]   nvarchar(100) null,
    [Full Face Respirator Date] datetime null,
    [Standard Respirator]    nvarchar(100) null,
    [Standard Respirator Date] datetime null,
    [Tdap]                   nvarchar(100) null,
    [Tdap Date]              datetime null,
    [TB West Campus]         nvarchar(100) null,
    [TB West Campus Date]    datetime null,
    [Supervisor Email]       nvarchar(100) null,
    [trainer]                varchar (500) NULL,
    [processed]              varchar (2000) NULL,
    [rowid]                     int NULL

    ) ON [PRIMARY]
    GO



CREATE TABLE [onprc_ehr_compliancedb].[OccHealthMasterTemp](
    [searchID] [int] IDENTITY(100,1) NOT NULL,
      Email                    nvarchar(500) null,
      [Person Type]            nvarchar(255) null,
      [Employee Status]        nvarchar(100) null,
      [Total Compliance]       nvarchar(100) null,
      [Hep B]                  nvarchar(100) null,
      [Hep B Date]             datetime null,
      [Measles]                nvarchar(100) null,
      [Measles Date]           datetime null,
      [Mumps]                  nvarchar(100) null,
      [Mumps Date]             datetime null,
      [Rubella]                nvarchar(100) null,
      [Rubella Date]           datetime null,
      [Varicella]              nvarchar(100) null,
      [Varicella Date]         datetime null,
      [Full Face Respirator]   nvarchar(100) null,
      [Full Face Respirator Date] datetime null,
      [Standard Respirator]    nvarchar(100) null,
      [Standard Respirator Date] datetime null,
      [Tdap]                   nvarchar(100) null,
      [Tdap Date]              datetime null,
      [TB West Campus]         nvarchar(100) null,
      [TB West Campus Date]    datetime null,
      [Supervisor Email]       nvarchar(100) null,
      [trainer]                varchar(500) NULL,
      [processed]              varchar(2000) NULL,
      [rowid]                   int NULL

    ) ON [PRIMARY]
    GO



