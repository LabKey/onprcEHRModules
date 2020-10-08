-- USE [Labkey]
-- GO
/****** Object:  StoredProcedure [extscheduler].[extBlockOutMorning]    Script Date: 5/13/2020 6:10:00 AM ******/
-- SET ANSI_NULLS ON
-- GO
-- SET QUOTED_IDENTIFIER ON
-- GO
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
DROP PROCEDURE IF EXISTS [extscheduler].[extBlockOutMorning]
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
