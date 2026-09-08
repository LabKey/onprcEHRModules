CREATE SCHEMA extscheduler;
GO

CREATE TABLE extscheduler.Resources
(
  Id INT IDENTITY(1,1) NOT NULL,
  Name VARCHAR(255) NOT NULL,
  Color VARCHAR(20),

  Container ENTITYID NOT NULL,
  CreatedBy USERID,
  Created DATETIME,
  ModifiedBy USERID,
  Modified DATETIME,

  CONSTRAINT PK_resources PRIMARY KEY (Id),
  CONSTRAINT UQ_resources_ContainerName UNIQUE (Container, Name)
);

CREATE TABLE extscheduler.Events
(
  Id INT IDENTITY(1,1) NOT NULL,
  ResourceId INT NOT NULL,
  Name VARCHAR(255) NOT NULL,
  StartDate DATETIME NOT NULL,
  EndDate DATETIME NOT NULL,
  UserId USERID NOT NULL,

  Container ENTITYID NOT NULL,
  CreatedBy USERID,
  Created DATETIME,
  ModifiedBy USERID,
  Modified DATETIME,

  CONSTRAINT PK_events PRIMARY KEY (Id),
  CONSTRAINT FK_events_ResourceId FOREIGN KEY (ResourceId) REFERENCES extscheduler.resources(Id),
  CONSTRAINT UQ_events_ContainerResourceName UNIQUE (Container, ResourceId, Name)
);

/* 15.xxx SQL scripts */

ALTER TABLE extscheduler.Resources Add Room VARCHAR(255);
ALTER TABLE extscheduler.Resources Add Bldg VARCHAR (255);


ALTER TABLE extscheduler.Events ADD  Alias VARCHAR(25);

CREATE TABLE extscheduler.users
(
  Id INT IDENTITY(1,1) NOT NULL,
  PrimeUserID USERID NOT NULL,
  FirstName VARCHAR(255) NOT NULL,
  LastName Varchar(255) NOT NULL,
  Email VARCHAR(255) NOT NULL,
  Phone VARCHAR(255),
  Department VARCHAR(255),
  Lab_FirstName VARCHAR(255),
  Lab_LastName VARCHAR(255),
  FiscalAuthority_Name VARCHAR(255),
  FiscalAuthority_Phone VARCHAR(255),
  SecurityLevel VARCHAR(255),
  Container ENTITYID NOT NULL,
  CreatedBy USERID,
  Created DATETIME,
  ModifiedBy USERID,
  Modified DATETIME,

  CONSTRAINT PK_users PRIMARY KEY (Id),
  CONSTRAINT FK_users_PrimeUserID FOREIGN KEY (PrimeUserID) REFERENCES core.Usersdata(UserId),
  CONSTRAINT UQ_users_ContainerPrimeUserID UNIQUE (Container, PrimeUserID)
);

DROP TABLE extscheduler.users;


CREATE TABLE extscheduler.users
(
  Id INT IDENTITY(1,1) NOT NULL,
  PrimeUserID USERID NOT NULL,
  FirstName VARCHAR(255) NOT NULL,
  LastName Varchar(255) NOT NULL,
  Email VARCHAR(255) NOT NULL,
  Phone VARCHAR(255),
  Department VARCHAR(255),
  Lab_FirstName VARCHAR(255),
  Lab_LastName VARCHAR(255),
  FiscalAuthority_Name VARCHAR(255),
  FiscalAuthority_Phone VARCHAR(255),
  SecurityLevel VARCHAR(255),
  Container ENTITYID NOT NULL,
  CreatedBy USERID,
  Created DATETIME,
  ModifiedBy USERID,
  Modified DATETIME,

  CONSTRAINT PK_users PRIMARY KEY (Id),
  CONSTRAINT FK_users_PrimeUserID FOREIGN KEY (PrimeUserID) REFERENCES core.Usersdata(UserId),
  CONSTRAINT UQ_users_ContainerPrimeUserID UNIQUE (Container, PrimeUserID)
);

ALTER TABLE extscheduler.events DROP CONSTRAINT UQ_events_ContainerResourceName;
ALTER TABLE extscheduler.events ADD CONSTRAINT CHK_event_DateRangeValid CHECK (StartDate <= EndDate);

GO

CREATE TRIGGER TR_OverlappingDateRanges ON extscheduler.events FOR INSERT, UPDATE AS
BEGIN
    IF EXISTS(
        SELECT 1 FROM extscheduler.events R
        INNER JOIN inserted I
        ON (
            (R.Container = I.Container AND R.ResourceId = I.ResourceId AND R.StartDate < I.EndDate AND I.StartDate < R.EndDate)
            AND NOT (R.Container = I.Container AND R.ResourceId = I.ResourceId AND R.StartDate = I.StartDate AND I.EndDate = R.EndDate)
        )
    )
    BEGIN
        RAISERROR('Start/End date ranges may not overlap for the same resource.', 16, 1)
        ROLLBACK
    END
END

GO

ALTER TABLE extscheduler.events ALTER COLUMN Name VARCHAR(255) NULL;

DROP TABLE extscheduler.users;

GO

ALTER TRIGGER extscheduler.TR_OverlappingDateRanges ON extscheduler.Events FOR INSERT, UPDATE AS
BEGIN
    IF EXISTS(
        SELECT 1 FROM extscheduler.events R
        INNER JOIN inserted I
        ON (
            (R.Container = I.Container AND R.ResourceId = I.ResourceId AND R.StartDate < I.EndDate AND I.StartDate < R.EndDate)
            AND NOT (R.Id = I.Id)
        )
    )
    BEGIN
        RAISERROR('Start/End date ranges may not overlap for the same resource.', 16, 1)
        ROLLBACK
    END
END

GO

ALTER TABLE extscheduler.Events ADD  Quantity INT;

ALTER TABLE extscheduler.Events ADD Comments VARCHAR(255);

GO

ALTER TRIGGER extscheduler.TR_OverlappingDateRanges ON extscheduler.Events FOR INSERT, UPDATE AS
BEGIN
    IF EXISTS(
        SELECT 1 FROM extscheduler.events R
        LEFT JOIN (
            SELECT ObjectId, Value FROM prop.Properties
            JOIN prop.PropertySets ON PropertySets."Set" = Properties."Set"
            WHERE Name = 'ExtSchedulerAllowEventOverlap'
        ) P ON R.Container = P.ObjectId
        INNER JOIN inserted I
        ON (P.Value IS NULL OR P.Value = 'false') AND (
            (R.Container = I.Container AND R.ResourceId = I.ResourceId AND R.StartDate < I.EndDate AND I.StartDate < R.EndDate)
            AND NOT (R.Id = I.Id)
        )
    )
    BEGIN
        RAISERROR('Start/End date ranges may not overlap for the same resource.', 16, 1)
        ROLLBACK
    END
END

GO

/* 20.xxx SQL scripts */

/*
Created:  2020-05-07
Created by jonesga
Purpose:  Update of Comments field of scheduler per user request

*/
ALTER TABLE extscheduler.Events ALTER COLUMN  Comments NVARCHAR(4000);

/*
Created:  2020-05-07
Created by jonesga
Purpose:  Dataset to mimic DateRange from Labkey for SCheduler actionin SQL

*/
EXEC core.fn_dropifexists 'DateParts','extScheduler','TABLE';
GO

CREATE TABLE extScheduler.dateParts
(date datetime,
dateOnly datetime,
DayOfYear int,
DayofMonth int,
DayofWeek int,
DayName varchar(20),

WeekofMonth int,
WeekofYear int,
 Month int,
 year int)

Go

Insert into  extScheduler.DateParts
    (Date,
    dateonly,
    DayOfYear,
    DayofMonth,
    DayofWeek,
    DayName,
    WeekofMonth,
    WeekofYear,
    Month,
    year)
Select

    i.NDate,
    CAST(i.Ndate as date) as dateOnly,
    cast(datepart(dy,i.Ndate) as integer) as DayOfYear,
    cast(datepart(dd,i.Ndate) as integer) as DayOfMonth,
    cast(datepart(dw,i.Ndate) as integer) as DayOfWeek,
    cast(dateName(dd,i.Ndate) as VarChar(20)) as DayName,
    (cast(datepart(dd,i.Ndate) as integer)/ 7) as WeekofMonth,
    cast(datepart(wk,i.Ndate) as integer) as WeekofYear,
    cast(datepart(mm,i.Ndate) as integer) as Month,
    cast(datepart(yyyy,i.Ndate) as integer) as Year
FROM (SELECT DateAdd(dd, i.value, '5/1/2020') as NDate FROM ldk.integers i)i
Where i.nDate <= '4/20/2021'

-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
-- =============================================
-- Author:		jonesga@ohsu.edu
-- Create date: 2020-05-13
-- Description:	PRocedure to Block out Scheduling for Covid19 testing for  3:30 to 7 PM on Monday and Friday
-- =============================================
EXEC core.fn_dropifexists 'extBlockOutEvening', 'extscheduler', 'PROCEDURE'
GO

CREATE PROCEDURE extscheduler.extBlockOutEvening
    -- Add the parameters for the stored procedure here
    @Month INTEGER, @ResourceID INTEGER
AS
BEGIN

    INSERT INTO [extscheduler].[Events]
    ([ResourceId]
    ,[Name]
    ,[StartDate]
    ,[EndDate]
    ,[UserId]
    ,[Container]
    ,[CreatedBy]
    ,[Created]
    ,[Quantity]
    ,[Comments])

    SELECT @ResourceID
         ,'No Covid-19 Testing'
         ,DateAdd(hh,1530,c.date) as StartDate
         ,DateAdd(hh,19,c.date) as EndDate
         ,1003
         ,'5C3C9FF8-6BCF-1038-930A-7D62F3A605B4'
         ,1003
         ,GetDate()
         ,1
         ,'Insert by ISE'
    FROM [Labkey].[extscheduler].[dateParts] c
    where c.dayofWeek in (2,6) and c.Month = @Month
--Days of Week start with Sunday



END
GO

/****** Object:  StoredProcedure [extscheduler].[extBlockOutMorning]    Script Date: 5/13/2020 6:10:00 AM ******/
-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters
-- command (Ctrl-Shift-M) to fill in the parameter
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
-- =============================================
-- Author:		jonesga@ohsu.edu
-- Create date: 2020-05-13
-- Description:	PRocedure to Block out Scheduling for Covid19 testing for  7 to 8 on Monday and Friday
-- =============================================
EXEC core.fn_dropifexists 'extBlockOutMorning', 'extscheduler', 'PROCEDURE'
GO

CREATE PROCEDURE [extscheduler].[extBlockOutMorning]
    -- Add the parameters for the stored procedure here
    @Month INTEGER, @ResourceID INTEGER
AS
BEGIN

    INSERT INTO [extscheduler].[Events]
    ([ResourceId]
    ,[Name]
    ,[StartDate]
    ,[EndDate]
    ,[UserId]
    ,[Container]
    ,[CreatedBy]
    ,[Created]
    ,[Quantity]
    ,[Comments])

    SELECT @ResourceID
         ,'No Covid-19 Testing'
         ,DateAdd(hh,7,c.date) as StartDate
         ,DateAdd(hh,8,c.date) as EndDate
         ,1003
         ,'5C3C9FF8-6BCF-1038-930A-7D62F3A605B4'
         ,1003
         ,GetDate()
         ,1
         ,'Insert by ISE'
    FROM [Labkey].[extscheduler].[dateParts] c
    where c.dayofWeek in (2,6) and c.Month = @Month
--Days of Week start with Sunday

END

GO

-- /****** Object:  StoredProcedure [extscheduler].[extBlockOutDays]    Script Date: 5/13/2020 6:12:06 AM ******/
-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters
-- command (Ctrl-Shift-M) to fill in the parameter
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
-- =============================================
-- Author:		jonesga@ohsu.edu
-- Create date: 2020-05-13
-- Description:	PRocedure to Block out Scheduling for Covid19 testing for all days except Monday and Friday
-- =============================================
EXEC core.fn_dropifexists 'extBlockOutDays', 'extscheduler', 'PROCEDURE'
GO

CREATE PROCEDURE [extscheduler].[extBlockOutDays]
    -- Add the parameters for the stored procedure here
    @Month INTEGER, @ResourceID INTEGER
AS
BEGIN

    INSERT INTO [extscheduler].[Events]
    ([ResourceId]
    ,[Name]
    ,[StartDate]
    ,[EndDate]
    ,[UserId]
    ,[Container]
    ,[CreatedBy]
    ,[Created]
    ,[Quantity]
    ,[Comments])

    SELECT @ResourceID
         ,'No Covid-19 Testing'
         ,DateAdd(hh,7,c.date) as StartDate
         ,DateAdd(hh,19,c.date) as EndDate
         ,1003
         ,'5C3C9FF8-6BCF-1038-930A-7D62F3A605B4'
         ,1003
         ,GetDate()
         ,1
         ,'Insert by ISE'
    FROM [Labkey].[extscheduler].[dateParts] c
    where c.dayofWeek in (1,3,4,5,7) and c.Month = @Month
--Days of Week start with Sunday

END

GO

EXEC core.fn_dropifexists 'vw_Covid19Research', 'extScheduler', 'VIEW', NULL;
GO

CREATE VIEW extScheduler.vw_Covid19Research AS
SELECT extscheduler.Events.Id AS SChedulerID, extscheduler.Events.ResourceId, extscheduler.Resources.Name AS ResourceName, extscheduler.Events.Name, extscheduler.Events.StartDate, extscheduler.Events.UserId,
       extscheduler.Events.CreatedBy, extscheduler.Events.Created, extscheduler.Events.Quantity, core.UsersData.IM AS EmployeeID
FROM     extscheduler.Events LEFT OUTER JOIN
         core.UsersData ON extscheduler.Events.UserId = core.UsersData.UserId LEFT OUTER JOIN
         extscheduler.Resources ON extscheduler.Events.ResourceId = extscheduler.Resources.Id
WHERE  (extscheduler.Events.ResourceId = 67);

GO

EXEC core.fn_dropifexists 'vw_Covid19DCMSchedule', 'extScheduler', 'VIEW', NULL;
GO

CREATE VIEW extScheduler.vw_Covid19DCMSchedule AS
SELECT extscheduler.Events.Id AS SChedulerID, extscheduler.Events.ResourceId, extscheduler.Resources.Name AS ResourceName, extscheduler.Events.Name, extscheduler.Events.StartDate, extscheduler.Events.UserId,
    extscheduler.Events.CreatedBy, extscheduler.Events.Created, extscheduler.Events.Quantity, core.UsersData.IM AS EmployeeID
    FROM     extscheduler.Events LEFT OUTER JOIN
    core.UsersData ON extscheduler.Events.UserId = core.UsersData.UserId LEFT OUTER JOIN
    extscheduler.Resources ON extscheduler.Events.ResourceId = extscheduler.Resources.Id
    WHERE  (extscheduler.Resources.Name LIKE 'DCM%');

GO

/****** Object:  Table [list].[c10437d746_covid19testing]    Script Date: 9/16/2020 9:19:28 AM ******/
EXEC core.fn_dropifexists 'Covid19Testing', 'extScheduler', 'TABLE', NULL;
GO

CREATE TABLE [extScheduler].[Covid19Testing](
    [container] [dbo].[ENTITYID] NOT NULL,
    [entityId] [dbo].[ENTITYID] NOT NULL,
    [lastIndexed] [datetime] NULL,
    [createdBy] [int] NULL,
    [modified] [datetime] NULL,
    [modifiedBy] [int] NULL,
    [created] [datetime] NULL,
    [Key] [int] IDENTITY(1,1) NOT NULL,
    [SchedulerID] [int] NULL,
    [ResourceID] [int] NULL,
    [UserName] [nvarchar](4000) NULL,
    [UserID] [int] NULL,
    [EmployeeID] [nvarchar](4000) NULL,
    [ScheduledDate] [datetime] NULL,
    [ScheduledTime] [datetime] NULL,
    [Create] [datetime] NULL,
    [SampleDate] [nvarchar](4000) NULL,
    [CreatedB] [nvarchar](4000) NULL,
    [ComplianceUpdated] [bit] NULL,
    CONSTRAINT [covid19testing_pk] PRIMARY KEY CLUSTERED
(
[Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO

/****** Object:  Table [list].[c10437d746_covid19testing]    Script Date: 9/16/2020 9:19:28 AM ******/
EXEC core.fn_dropifexists 'Covid19Testing', 'extScheduler', 'TABLE', NULL;
GO

CREATE TABLE [extScheduler].[Covid19Testing](
    [container] [dbo].[ENTITYID] NOT NULL,
    [entityId] [dbo].[ENTITYID] NOT NULL,
    [lastIndexed] [datetime] NULL,
    [createdBy] [int] NULL,
    [modified] [datetime] NULL,
    [modifiedBy] [int] NULL,
    [created] [datetime] NULL,
    [Key] [int] IDENTITY(1,1) NOT NULL,
    [SchedulerID] [int] NULL,
    [ResourceID] [int] NULL,
    [UserName] [nvarchar](4000) NULL,
    [UserID] [int] NULL,
    [EmployeeID] [nvarchar](4000) NULL,
    [ScheduledDate] [datetime] NULL,
    [ScheduledTime] [datetime] NULL,
    [Create] [datetime] NULL,
    [SampleDate] [nvarchar](4000) NULL,
    [CreatedB] [nvarchar](4000) NULL,
    [ComplianceUpdated] [bit] NULL,
    CONSTRAINT [covid19testingKey_pk] PRIMARY KEY CLUSTERED
(
[Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO

EXEC core.fn_dropifexists 'TempScheduler', 'extScheduler', 'TABLE', NULL;
GO

CREATE TABLE [extscheduler].[TempScheduler](
    [Searchkey] [int] IDENTITY(100,1) NOT NULL,
    [usernames] [varchar](500) NULL,
    [EventId] [varchar](max) NULL,
    [StartDate] [smalldatetime] NULL,
    [created] [smalldatetime] NULL
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO

EXEC core.fn_dropifexists 'TempCoV19Interim', 'extScheduler', 'TABLE', NULL;
GO

/****** Object:  Table [extscheduler].[TempScheduler]
  ONCE TESTED CHAN GE TO labkey_public
  Script Date: 10/29/2020 8:19:18 AM ******/

CREATE TABLE [extscheduler].[TempCoV19Interim](
    [EventId] [varchar](max) NULL,
    [UserName] [nvarchar](1000) NULL,
    [container] [varchar](max) NULL,
    [notes] nvarchar(100) null
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO

EXEC core.fn_dropifexists 'TempCoV19Interim', 'extScheduler', 'TABLE', NULL;
GO

CREATE TABLE [extscheduler].[TempCoV19Interim](
    [EventId] [varchar](max) NULL,
    [UserName] [nvarchar](1000) NULL,
    [container] [varchar](max) NULL
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO

EXEC core.fn_dropifexists 'TempCoV19Final', 'extScheduler', 'TABLE', NULL;
    GO

CREATE TABLE [extscheduler].[TempCoV19Final](
    [container] [uniqueidentifier] NOT NULL,
    [UserName] [nvarchar](4000) NULL,
    [UserID] [int] NULL,
    [EventID] [int] NULL,
    [StartDate] [smalldatetime] NULL,
    [EmployeeID] [nvarchar](4000) NULL,
    [Created] [smalldatetime] NULL
    ) ON [PRIMARY]
    GO

/* 21.xxx SQL scripts */

ALTER TABLE extscheduler.Resources ADD  Instance varchar(50);

/* 23.xxx SQL scripts */

EXEC core.fn_dropifexists 'TempCoV19Final', 'extScheduler', 'TABLE', NULL;
    GO
EXEC core.fn_dropifexists 'covid19testing', 'extScheduler', 'TABLE', NULL;
GO

EXEC core.fn_dropifexists 'tempscheduler', 'extScheduler', 'TABLE', NULL;
GO

EXEC core.fn_dropifexists 'TempCoV19Interim', 'extScheduler', 'TABLE', NULL;
GO

EXEC core.fn_dropifexists 'vw_Covid19Research', 'extScheduler', 'VIEW', NULL;
GO

EXEC core.fn_dropifexists 'vw_covid19dcmschedule', 'extScheduler', 'VIEW', NULL;
GO

EXEC core.fn_dropifexists 'vw_Covid19DCMDaily', 'extScheduler', 'VIEW', NULL;
GO