/****** Covid 19 scheduling project: By Kolli******/
/*
 Created these temp tables and a view
 */
EXEC core.fn_dropifexists 'TempCov19ReoccurringEvents','extscheduler','TABLE';
EXEC core.fn_dropifexists 'Covid19_ReoccurringEvents', 'extscheduler', 'PROCEDURE'

GO

CREATE TABLE [extscheduler].[TempCov19ReoccurringEvents](
    [Row] [int] NULL,
    [Id] [int] NOT NULL,
    [ResourceId] [int] NOT NULL,
    [Name] [varchar](255) NULL,
    [StartDate] [smalldatetime] NOT NULL,
    [EndDate] [smalldatetime] NOT NULL,
    [UserId] [int] NOT NULL,
    [Container] [uniqueidentifier] NOT NULL,
    [CreatedBy] [int] NULL,
    [Created] [smalldatetime] NULL,
    [ModifiedBy] [int] NULL,
    [Modified] [datetime] NULL,
    [Alias] [varchar](100) NULL,
    [Quantity] [int] NULL,
    [Comments] [nvarchar](max) NULL
    )
;
GO

-- =======================================================================================================================================
-- Author:		Lakshmi Kolli
-- Create date: 2021-04-26
-- Description:	This stored procedure processes re-occurring COVID calendar events into individual events within the specified date range.
-- =======================================================================================================================================

CREATE PROCEDURE [extscheduler].[Covid19_ReoccurringEvents]
AS

DECLARE
@week_count		Int,
	@counter		Int,
	@num_events		Int,
	@week_counter	Int,
	@R_Id			Int,
	@starting_date	smalldatetime

BEGIN

	--Get the ResourceId of the newly created resource
Select @R_Id = Id From extscheduler.Resources Where Name like 'Covid_Reoccurring_Event'

--Get the re-occurring events count
Select  @num_events = count(*)
From extscheduler.Events e, core.containers c
Where c.EntityId = e.container And c.Name like 'COVID-19 Testing Calendar'
  And (DatePart(WEEK, e.EndDate) - DatePart(WEEK,e.StartDate)) > 0
  And e.ResourceId <> @R_Id

  --Processing the reoccuring events starts here...
    If (@num_events > 0)
Begin

--1. Clear the temp table first
--Delete data from the temp table: TempCov19ReoccurringEvents
Delete Labkey_test.extscheduler.TempCov19ReoccurringEvents
    If @@Error <> 0
    GoTo Err_Proc

--2. Insert the reoccuring events rows into the temp table: TempCov19ReoccurringEvents
Insert Into Labkey_test.extscheduler.TempCov19ReoccurringEvents
(Row, Id, ResourceId, Name, StartDate, EndDate, UserId, Container, CreatedBy, Created, ModifiedBy, Modified, Alias, Quantity, Comments)
Select
            Row_number() Over (order by e.Id) as Row, --This line of code generates a row num to each record starting from 1.
            e.Id,
            e.ResourceId,
            e.Name,
            e.StartDate,
            e.EndDate,
            e.UserId,
            e.Container,
            e.CreatedBy,
            e.Created,
            e.ModifiedBy,
            e.Modified,
            e.Alias,
            e.Quantity,
            e.Comments
From extscheduler.Events e, core.containers c
Where c.EntityId = e.container And c.Name like 'COVID-19 Testing Calendar'
  And (DatePart(ISO_WEEK, e.EndDate) - DatePart(ISO_WEEK,e.StartDate)) > 0
  And e.ResourceId <> @R_Id

--3. Read each row from the temp table and create individual events based on the weekcount using 'StartDate' as the starting date
--Set the num rows counter to 1
Select @counter = 1
           While (@counter <= @num_events) --Start while #1
        Begin

--Get num of weeks of the processing row based on the start and end dates
Select @week_count = (DatePart(WEEK,[EndDate]) - DatePart(WEEK,[StartDate]))
From Labkey_test.extscheduler.TempCov19ReoccurringEvents
Where Row = @counter

--Get the starting date of the processing row
Select @starting_date = (Select StartDate From Labkey_test.extscheduler.TempCov19ReoccurringEvents Where Row = @counter)

           --Update the reoccuring event resource to the newly created resource.
           --If we dont change the resource the individual events cannot be created as the entire date range is blocked by the resource and the overlapping constriant stops the insert.
           Update extscheduler.Events
                        Set ResourceId = @R_Id
Where Id = (Select Id From Labkey_test.extscheduler.TempCov19ReoccurringEvents Where Row = @counter)

--Set the week counter to 1
Select @week_counter = 1
           While (@week_counter <= @week_count) -- Start while #2
            Begin
                --Insert an individual row into events table
                Insert into extscheduler.Events	(ResourceId, Name, StartDate, EndDate, UserId, Container, CreatedBy, Created, ModifiedBy, Modified, Alias, Quantity, Comments)
Select
    ResourceId,
    Name,
    DATEADD(WEEK, @week_counter-1, @starting_date),
    DATEADD(WEEK, @week_counter-1, DATEADD(MINUTE,5,@starting_date)), --Set to 5 mins appt slot. Change it accordingly...
    UserId,
    Container,
    CreatedBy,
    Created,
    1003, --onprcitsupport
    GETDATE(),
    Alias,
    Quantity,
    Comments
From Labkey_test.extscheduler.TempCov19ReoccurringEvents
Where Row = @counter

--increment the counter
SET @week_counter = @week_counter + 1

End --End while #2

--Catch the last one here and update the resource:
Update extscheduler.Events
Set ResourceId = @R_Id
Where Id = (Select Id From Labkey_test.extscheduler.TempCov19ReoccurringEvents Where Row = @counter)

--increment the counter to go to the next record
SET @counter = @counter + 1

End --End while #1

End --End If

    RETURN 0

    Err_Proc:
		RETURN 1
END

GO