USE [Labkey]
GO
/****** Object:  StoredProcedure [extscheduler].[extBlockOutDays]    Script Date: 5/13/2020 6:12:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
DROP PROCEDURE IF EXISTS [extscheduler].[extBlockOutDays]
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
