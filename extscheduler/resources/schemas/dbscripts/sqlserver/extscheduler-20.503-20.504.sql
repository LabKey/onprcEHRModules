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
