USE [Labkey_test]
GO
/****** Object:  StoredProcedure [extscheduler].[cov19ScheduleProcessDCM]    Script Date: 4/19/2021 10:53:19 AM ******/
SET ANSI_NULLS ON
    GO
SET QUOTED_IDENTIFIER ON
    GO


ALTER Procedure [extscheduler].[cov19ScheduleProcessDCM]
    AS

DECLARE
@SearchKey		Int,
	@TempsearchKey	Int,
	@EventId        Varchar(4000),
	@Username       Varchar(500),
	@NewSearchName  Varchar(500),
	@SearchName     Varchar(500),
	@TempName		Varchar(200),
	@Newpos         Smallint,
	@EmployeeID     Int,
	@UserId			Int,
	@startDate		DateTime,
	@container      Varchar(50)
              
BEGIN
	-- Reset temp tables		
Delete Labkey_test_public.extscheduler.TempScheduler
    If @@Error <> 0
    GoTo Err_Proc

Delete Labkey_test_Public.extscheduler.TempCoV19Interim
    If @@Error <> 0
    GoTo Err_Proc

Delete Labkey_test_Public.extscheduler.TempCoV19Final
    If @@Error <> 0
    GoTo Err_Proc

Insert into Labkey_test_Public.extscheduler.TempScheduler
Select a.comments, a.id, getDate(), a.startDate From [Labkey_test].[extScheduler].[vw_Covid19DCMDaily] a

    If @@Error <> 0
    GoTo Err_Proc

-- Initialize all variables
Set @TempsearchKey = 0
Set @SearchKey = 0

--Get the container
Set @container = (Select top 1 container FROM [Labkey_test].[extscheduler].[Events] where resourceID = 67)

-- Extract username one record at a time
Select Top 1 @Searchkey = searchKey From [Labkey_test_Public].[extscheduler].TempScheduler Order by searchkey
    While @TempSearchKey < @SearchKey
BEGIN
Set @EventId = Null
Set @Username = ''
Set @SearchName = ''
Set @NewSearchName = ''
Set @TempName = ''
Set @EmployeeID = Null
Set @startDate = Null
--Set @container = Null

Select @Username = LTRIM(RTRIM(usernames)), @EventId = eventid, @startDate = startDate From [Labkey_test_Public].[extscheduler].TempScheduler Where searchkey = @SearchKey

Set @NewPos = 0
Set @NewSearchName = @Username
Set @NewPos = CHARINDEX(',',@NewSearchName)

    --If no comma in the string, means error in the data. But, still insert the record into the Cov19 table with no other user credentials
    If @NewPos = 0
BEGIN
If Exists (Select userid From [Labkey_test].Core.Users Where LTRIM(RTRIM(substring(Email, 1, CHARINDEX('@',Email)-1))) = @NewSearchName)
			BEGIN
				-- Extract individual userId and empId
Set @userId = 0
Set @EmployeeId = 0
Select @UserId = userid, @EmployeeId = IM From [Labkey_test].Core.Users Where LTRIM(RTRIM(substring(Email, 1, CHARINDEX('@',Email)-1))) = @NewSearchName

-- Generate a scheduler record
Insert into [Labkey_test_Public].extscheduler.TempCoV19Interim (Username,Userid,eventID,employeeid,created,startDate,container)
Values (LTRIM(RTRIM(@NewSearchName)),@UserId,@EventId,@EmployeeId,getdate(),@startDate,@container)

    If @@Error <> 0
					GoTo Err_Proc
END --(if exists)
END

    --If comma delimited string of usernames, split and loop through the user names
    While (@NewPos > 1)
BEGIN
Set @SearchName = LTRIM(RTRIM(@NewSearchName))
Set @NewPos =  CHARINDEX(',',@Searchname)
Set @TempName =  LTRIM(RTRIM(SUBSTRING(@SearchName,1,@NewPos -1)))
Set @NewSearchname = RIGHT(@SearchName,LEN(@SearchName) - @NewPos)

    If Exists (Select userid From [Labkey_test].Core.Users Where LTRIM(RTRIM(substring(Email, 1, CHARINDEX('@',Email)-1))) = @TempName)
BEGIN
-- Extract individual userId and empId
Set @userId = 0
Set @EmployeeId = 0
Select @UserId = userid, @EmployeeId = IM From [Labkey_test].Core.Users Where LTRIM(RTRIM(substring(Email, 1, CHARINDEX('@',Email)-1))) = @TempName

-- Generate a scheduler record
Insert into [Labkey_test_Public].extscheduler.TempCoV19Interim (Username,Userid,eventID,employeeid,created,startDate,container)
Values (@TempName,@Userid,@EventId,@EmployeeID,getdate(),@startDate,@container)

    If @@Error <> 0
					GoTo Err_Proc
END --(if exists)
END   --(While)

-- Extract the last string name
Select  @EventID = eventid, @startDate = startDate From [Labkey_test_Public].[extscheduler].TempScheduler Where searchkey = @SearchKey

    If LEN(@NewSearchName) > 0
BEGIN
-- Extract individual userId and empId
Set @userId = 0
Set @EmployeeId = 0
Select @UserId = userId, @EmployeeId = IM From [Labkey_test].Core.Users Where LTRIM(RTRIM(substring(Email, 1, CHARINDEX('@',Email)-1))) = rtrim(ltrim(@NewSearchName))

Insert into [Labkey_test_Public].extscheduler.TempCoV19Interim (Username,Userid,eventID,employeeid,created,startDate,container)
Values (LTRIM(RTRIM(@NewSearchName)),@Userid,@EventId,@EmployeeID,getdate(),@startDate,@container)

    If @@Error <> 0
			GoTo Err_Proc
END --(If)

Set @TempSearchkey = @Searchkey
Select Top 1 @Searchkey = searchKey From [Labkey_test_Public].extscheduler.TempScheduler Where searchkey > @Tempsearchkey Order by searchkey

END  --(While)

--To avoid duplicates, get the distinct records from LIS.TempCoV19Interim and insert them into LIS.TempCoV19Final
INSERT into [Labkey_test_Public].extscheduler.TempCoV19Final (container,EventId,UserName,UserID,EmployeeID,Created,startDate)
SELECT distinct container,EventId,UserName,UserID,EmployeeID,Created,startDate
FROM [Labkey_test_Public].extscheduler.TempCoV19Interim

    RETURN 0

    Err_Proc:
    RETURN 1
END