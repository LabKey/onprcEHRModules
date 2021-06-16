--2021-05-25 Modified Stored Procedure to Address modification of Processing to Events DB
--Created by KolliL
--update 2021-06-16 to add to new build

/****** Object:  StoredProcedure [extscheduler].[Covid19_ScheduleProcessDCM]    Script Date: 5/25/2021 5:27:25 AM ******/
EXEC core.fn_dropifexists 'Covid19_ScheduleProcessDCM', 'extscheduler', 'PROCEDURE';
GO
SET ANSI_NULLS ON
    GO
SET QUOTED_IDENTIFIER ON
    GO
ALTER Procedure [extscheduler].[Covid19_ScheduleProcessDCM]
    AS

DECLARE
@SearchKey		Int,
	@TempsearchKey	Int,
	@EventId        nvarchar(100),
	@ResourceId     Int,
	@Username       nvarchar(max),
	@NewSearchName  nvarchar(max),
	@SearchName     nvarchar(max),
	@TempName		nvarchar(max),
	@Newpos         Int,
	@EmployeeID     Int,
	@UserId			Int,
	@StartDate		SmallDateTime,
	@Container      nvarchar(100)

BEGIN

Delete [extscheduler].[TempScheduler]
    If @@Error <> 0
    GoTo Err_Proc

Delete [extscheduler].[TempCoV19Interim]
    If @@Error <> 0
    GoTo Err_Proc

Delete [extscheduler].[TempCoV19Final]
    If @@Error <> 0
    GoTo Err_Proc


Insert into [extscheduler].[TempScheduler]
Select a.Comments, a.id, a.ResourceId, getDate(), a.StartDate From [extScheduler].[vw_Covid19DCMDaily] a
    If @@Error <> 0
    GoTo Err_Proc

Set @TempsearchKey = 0
Set @SearchKey = 0

Select @Container = EntityId
From extscheduler.Events e, core.containers c
Where c.EntityId = e.container And c.Name like 'COVID-19 Testing Calendar'

Select Top 1 @Searchkey = SearchKey From [extscheduler].[TempScheduler] Order by Searchkey

    While @TempSearchKey < @SearchKey
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
			--If Exists (Select userId From [extscheduler].[vw_Cov19Users] Where LTRIM(RTRIM(UserName)) = @NewSearchName)
			BEGIN
Set @UserId = 0
Set @EmployeeId = 0
Select @UserId = UserId, @EmployeeId = IM From Core.Users Where LTRIM(RTRIM(substring(Email, 1, CHARINDEX('@',Email)-1))) = @NewSearchName
--Select @UserId = UserId, @EmployeeId = EmployeeId From [extscheduler].[vw_Cov19Users] Where LTRIM(RTRIM(UserName)) = @NewSearchName

Insert Into extscheduler.TempCoV19Interim (Username, UserId, EventId, ResourceId, EmployeeId, Created, StartDate, Container)
Values (LTRIM(RTRIM(@NewSearchName)), @UserId, @EventId, @ResourceId, @EmployeeId, GETDATE(), @StartDate, @Container)

    If @@Error <> 0
						GoTo Err_Proc
END
END

    While (@NewPos > 1)
BEGIN
--Set @SearchName = LTRIM(RTRIM(@NewSearchName))
--Set @NewPos =  CHARINDEX(',',@Searchname)
--Set @TempName =  LTRIM(RTRIM(SUBSTRING(@SearchName,1,@NewPos -1)))
--Set @NewSearchname = RIGHT(@SearchName,LEN(@SearchName) - @NewPos)
Set @SearchName = LTRIM(RTRIM(@NewSearchName))
Set @NewPos =  CHARINDEX(',',@Searchname)
Set @TempName = (Select SUBSTRING(@SearchName,1,
    CASE WHEN @NewPos -1 < 0
    THEN LEN(@SearchName)
    ELSE @NewPos - 1 END) )
Set @NewSearchname = RIGHT(@SearchName,LEN(@SearchName) - @NewPos)

    If Exists (Select UserId From Core.Users Where LTRIM(RTRIM(substring(Email, 1, CHARINDEX('@',Email)-1))) = @TempName)
--If Exists (Select UserId From [extscheduler].[vw_Cov19Users] Where UserName = @TempName)
BEGIN

Set @userId = 0
Set @EmployeeId = 0
Select @UserId = UserId, @EmployeeId = IM From Core.Users Where LTRIM(RTRIM(substring(Email, 1, CHARINDEX('@',Email)-1))) = @TempName
--Select @UserId = UserId, @EmployeeId = EmployeeId From [extscheduler].[vw_Cov19Users] Where LTRIM(RTRIM(UserName)) = @TempName

Insert into extscheduler.TempCoV19Interim (UserName, UserId, EventId, ResourceId, Employeeid, Created, StartDate, Container)
Values (@TempName, @UserId, @EventId, @ResourceId, @EmployeeId, GETDATE(), @StartDate, @Container)

    If @@Error <> 0
					GoTo Err_Proc
END
END

Select  @EventID = EventId, @StartDate = StartDate From [extscheduler].TempScheduler Where Searchkey = @SearchKey

    If LEN(@NewSearchName) > 0
BEGIN
Set @UserId = 0
Set @EmployeeId = 0
Select @UserId = UserId, @EmployeeId = IM From Core.Users Where LTRIM(RTRIM(substring(Email, 1, CHARINDEX('@',Email)-1))) = rtrim(ltrim(@NewSearchName))
--Select @UserId = UserId, @EmployeeId = EmployeeId From [extscheduler].[vw_Cov19Users] Where LTRIM(RTRIM(UserName)) = rtrim(ltrim(@NewSearchName))

Insert into extscheduler.TempCoV19Interim (Username, UserId, EventId, ResourceId, Employeeid, Created, StartDate, Container)
Values (LTRIM(RTRIM(@NewSearchName)), @Userid, @EventId, @ResourceId, @EmployeeID, GETDATE(), @StartDate, @Container)

    If @@Error <> 0
							GoTo Err_Proc
END

Set @TempSearchkey = @Searchkey
Select Top 1 @Searchkey = SearchKey From extscheduler.TempScheduler Where SearchKey > @Tempsearchkey Order by searchkey

END

INSERT into extscheduler.TempCoV19Final (Container, EventId, ResourceId, UserName, UserID, EmployeeID, Created, StartDate)
SELECT distinct Container, EventId, ResourceId, UserName, UserID, EmployeeID, Created, StartDate
FROM extscheduler.TempCoV19Interim

         INSERT into extscheduler.Events(Container, ResourceID, Id, Name, UserID, EmployeeID, Created, CreatedBy, DateDisabled)
SELECT distinct Container, ResourceID, EventID, UserName, UserID, EmployeeID, Created, 1003, NULL
FROM extscheduler.TempCoV19Interim

         RETURN 0

    Err_Proc:
    RETURN 1

END
;