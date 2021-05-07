/****** Covid 19 scheduling project: By Kolli******/
/*
 Created these temp tables and a view
 */
EXEC core.fn_dropifexists 'TempScheduler','extscheduler','TABLE';
EXEC core.fn_dropifexists 'TempCov19Interim','extscheduler','TABLE';
EXEC core.fn_dropifexists 'TempCov19Final','extscheduler','TABLE';
EXEC core.fn_dropifexists 'Covid19Testing','extscheduler','TABLE';
EXEC core.fn_dropifexists 'vw_Covid19DCMDaily','extscheduler','VIEW';
EXEC core.fn_dropifexists 'Covid19_ScheduleProcessDCM', 'extscheduler', 'PROCEDURE'

GO

CREATE TABLE [extscheduler].[TempScheduler](
    [Searchkey] [int] IDENTITY(100,1) NOT NULL,
    [UserName] [varchar](5000) NULL,
    [EventId] [nvarchar](100) NULL,
    [ResourceID] [int] NULL,
    [StartDate] [smalldatetime] NULL,
    [Created] [smalldatetime] NULL
    )
;

CREATE TABLE [extscheduler].[TempCov19Interim](
    [UserName] [nvarchar](max) NULL,
    [Userid] [int] NULL,
    [EventId] [nvarchar](100) NULL,
    [ResourceID] [int] NULL,
    [Employeeid] [nvarchar](100) NULL,
    [Created] [smalldatetime] NULL,
    [StartDate] [smalldatetime] NULL,
    [Container] [uniqueidentifier] NOT NULL,
    [Notes] [nvarchar](max) NULL
    )
;

CREATE TABLE [extscheduler].[TempCov19Final](
    [Container] [uniqueidentifier] NOT NULL,
    [UserName] [nvarchar](max) NULL,
    [UserID] [int] NULL,
    [EventID] [nvarchar](100) NULL,
    [ResourceID] [int] NULL,
    [StartDate] [smalldatetime] NULL,
    [EmployeeID] [nvarchar](100) NULL,
    [Created] [smalldatetime] NULL
    )
;

CREATE TABLE [extscheduler].[Covid19Testing](
    [EntityId] [dbo].[ENTITYID] NOT NULL,
    [Key] [int] IDENTITY(1,1) NOT NULL,
    [ResourceID] [int] NULL,
    [EventID] [int] NULL,
    [ScheduledDate] [datetime] NULL,
    [ScheduledTime] [datetime] NULL,
    [UserName] [nvarchar](4000) NULL,
    [UserID] [int] NULL,
    [EmployeeID] [nvarchar](4000) NULL,
    [Created] [datetime] NULL,
    [CreatedBy] [int] NULL,
    [Modified] [datetime] NULL,
    [ModifiedBy] [int] NULL,
    [Recorded] [smalldatetime] NULL,
    [RecordedBy] [int] NULL,
    [ComplianceUpdated] [bit] NULL,
    [DateCompleted] [smalldatetime] NULL
    )
;
GO

--Create the view here
CREATE VIEW [extscheduler].[vw_Covid19DCMDaily]
AS
SELECT
    e.Id,
    e.StartDate,
    e.Container,
    e.Comments,
    e.ResourceId,
    e.Quantity,
    t.EventID
FROM extscheduler.Events e LEFT OUTER JOIN extscheduler.Covid19Testing t
                                           ON e.Id = t.EventID
WHERE  (e.Quantity > 1) AND (e.StartDate > '5/1/2021') AND (e.Comments NOT LIKE '%-%')
;
GO

--Stored procs start here
-- =======================================================================================================================================
-- Author:		Lakshmi Kolli
-- Create date: 2021-04-26
-- Description:	This stored procedure parses the participants for COVID calendar events.
-- =======================================================================================================================================

CREATE Procedure [extscheduler].[Covid19_ScheduleProcessDCM]
AS

DECLARE
@SearchKey		Int,
	@TempsearchKey	Int,
	@EventId        Varchar(100),
	@ResourceId     Int,
	@Username       Varchar(5000),
	@NewSearchName  Varchar(5000),
	@SearchName     Varchar(5000),
	@TempName		Varchar(200),
	@Newpos         Smallint,
	@EmployeeID     Int,
	@UserId			Int,
	@StartDate		SmallDateTime,
	@Container      Varchar(100)

BEGIN
        --Clear the data from temp tables
Delete extscheduler.TempScheduler
    If @@Error <> 0
    GoTo Err_Proc

Delete extscheduler.TempCoV19Interim
    If @@Error <> 0
    GoTo Err_Proc

Delete extscheduler.TempCoV19Final
    If @@Error <> 0
    GoTo Err_Proc

--Get data to process from the view
Insert into extscheduler.TempScheduler
Select a.Comments, a.id, a.ResourceId, getDate(), a.StartDate From [extScheduler].[vw_Covid19DCMDaily] a

    If @@Error <> 0
    GoTo Err_Proc

--Initialize the values before processing starts
Set @TempsearchKey = 0
Set @SearchKey = 0

-- Get the covid containerId
Select @Container = EntityId
From extscheduler.Events e, core.containers c
Where c.EntityId = e.container And c.Name like 'COVID-19 Testing Calendar'

Select Top 1 @Searchkey = SearchKey From [extscheduler].TempScheduler Order by Searchkey

    --Parsing process starts here
    While @TempSearchKey < @SearchKey --Begin While #1
BEGIN
Set @EventId = Null
Set @Username = ''
Set @SearchName = ''
Set @NewSearchName = ''
Set @TempName = ''
Set @EmployeeID = Null
Set @StartDate = Null

Select @Username = LTRIM(RTRIM(UserName)), @EventId = EventId, @ResourceId = ResourceId,  @StartDate = StartDate From [extscheduler].TempScheduler Where Searchkey = @SearchKey

Set @NewPos = 0
Set @NewSearchName = @Username
Set @NewPos = CHARINDEX(',',@NewSearchName)

    If @NewPos = 0
BEGIN
If Exists (Select userid From Core.Users Where LTRIM(RTRIM(substring(Email, 1, CHARINDEX('@',Email)-1))) = @NewSearchName)
            BEGIN
Set @userId = 0
Set @EmployeeId = 0
Select @UserId = UserId, @EmployeeId = IM From Core.Users Where LTRIM(RTRIM(substring(Email, 1, CHARINDEX('@',Email)-1))) = @NewSearchName

Insert Into extscheduler.TempCoV19Interim (Username, UserId, EventId, ResourceId, EmployeeId, Created, StartDate, Container)
Values (LTRIM(RTRIM(@NewSearchName)), @UserId, @EventId, @ResourceId, @EmployeeId, GETDATE(), @StartDate, @Container)

    If @@Error <> 0
                    GoTo Err_Proc
END
END

    While (@NewPos > 1)--Begin While #2
BEGIN
Set @SearchName = LTRIM(RTRIM(@NewSearchName))
Set @NewPos =  CHARINDEX(',',@Searchname)
Set @TempName =  LTRIM(RTRIM(SUBSTRING(@SearchName,1,@NewPos -1)))
Set @NewSearchname = RIGHT(@SearchName,LEN(@SearchName) - @NewPos)

    If Exists (Select UserId From Core.Users Where LTRIM(RTRIM(substring(Email, 1, CHARINDEX('@',Email)-1))) = @TempName)
BEGIN

Set @userId = 0
Set @EmployeeId = 0
Select @UserId = UserId, @EmployeeId = IM From Core.Users Where LTRIM(RTRIM(substring(Email, 1, CHARINDEX('@',Email)-1))) = @TempName

Insert into extscheduler.TempCoV19Interim (UserName, UserId, EventId, ResourceId, Employeeid, Created, StartDate, Container)
Values (@TempName, @UserId, @EventId, @ResourceId, @EmployeeId, GETDATE(), @StartDate, @Container)

    If @@Error <> 0
                    GoTo Err_Proc
END
END--End While #2

Select  @EventID = EventId, @StartDate = StartDate From [extscheduler].TempScheduler Where Searchkey = @SearchKey

    If LEN(@NewSearchName) > 0
BEGIN
Set @UserId = 0
Set @EmployeeId = 0
Select @UserId = UserId, @EmployeeId = IM From Core.Users Where LTRIM(RTRIM(substring(Email, 1, CHARINDEX('@',Email)-1))) = rtrim(ltrim(@NewSearchName))

Insert into extscheduler.TempCoV19Interim (Username, UserId, EventId, ResourceId, Employeeid, Created, StartDate, Container)
Values (LTRIM(RTRIM(@NewSearchName)), @Userid, @EventId, @ResourceId, @EmployeeID, GETDATE(), @StartDate, @Container)

    If @@Error <> 0
                GoTo Err_Proc
END

Set @TempSearchkey = @Searchkey
Select Top 1 @Searchkey = SearchKey From extscheduler.TempScheduler Where SearchKey > @Tempsearchkey Order by searchkey

END -- End While #1

--Insert the data into the final temp table
INSERT into extscheduler.TempCoV19Final (Container, EventId, ResourceId, UserName, UserID, EmployeeID, Created, StartDate)
SELECT distinct Container, EventId, ResourceId, UserName, UserID, EmployeeID, Created, StartDate
FROM extscheduler.TempCoV19Interim

         --Insert the above data into the Covid19testing table too
         INSERT into extscheduler.Covid19Testing(EntityId, ResourceID, EventID, UserName, UserID, EmployeeID, Created, CreatedBy)
SELECT distinct Container, ResourceID, EventID, UserName, UserID, EmployeeID, Created, 1003 --onprcitsupport
FROM extscheduler.TempCoV19Interim

         RETURN 0

    Err_Proc:
    RETURN 1

END

GO

