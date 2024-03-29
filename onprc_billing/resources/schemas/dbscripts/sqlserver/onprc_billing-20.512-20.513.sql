
/****** Object:  StoredProcedure [onprc_billing].[oga_InsertRecords]    Script Date: 5/18/2020 10:35:50 AM ******/
EXEC core.fn_dropifexists 'oga_InsertRecords', 'onprc_billing', 'PROCEDURE'
GO

CREATE PROCEDURE [onprc_billing].[oga_InsertRecords]

    AS
    BEGIN

        INSERT INTO [onprc_billing].[aliases]
        ([alias]
        ,[aliasEnabled]
        ,[projectNumber]
        ,[grantNumber]
        ,[agencyAwardNumber]
        ,[investigatorId]
        ,[investigatorName]
        ,[fiscalAuthority]
        ,[container]
        ,[createdBy]
        ,[created]
        ,[category]
        ,[faRate]
        ,[faSchedule]
        ,[budgetStartDate]
        ,[budgetEndDate]
        ,[projectTitle]
        ,[projectDescription]
        ,[projectStatus]
        ,[aliasType]
        ,[COMMENTS]
        ,[PPQNumber]
        ,[PPQDate]
        ,[AwardStatus]
        ,[AwardID]
        ,[ApplicationType]
        ,[ProjectID]
        ,[ActivityType]
        ,[AwardNumber]
        ,[AwardSuffix]
        ,[ADFMEmpNum]
        ,[ADFMFullName]
        ,[Org]
        )
        SELECT
            [Alias]
             ,[ALIAS ENABLED FLAG_MVIndicator]
             ,[OGA PROJECT NUMBER]
             ,[OGA AWARD NUMBER]
             ,[AGENCY AWARD NUMBER]
             ,[PI EMP NUM]
             ,[PI FULL NAME]
             ,[PDFM EMP NUM]
             ,'0F8BB08E-E4BF-102F-B89B-5107380A5B61'
             ,1003
             ,GetDate()
             ,'OGA'
             ,[BURDEN RATE]
             ,[BURDEN SCHEDULE]
             ,[CURRENT BUDGET START DATE]
             ,[CURRENT BUDGET END DATE]
             ,[PROJECT TITLE]
             ,[PROJECT DESCRIPTION]
             ,[PROJECT STATUS]
             ,[ACTIVITY TYPE]
             ,'ENTERED BY ISE'
             ,[PPQ CODE]
             ,[PPQ DATE]
             ,[AWARD STATUS]
             ,[AWARD ID]
             ,[APPLICATION TYPE]
             ,[PROJECT ID]
             ,[OGA AWARD TYPE]
             ,[AWARD NUMBER]
             ,[AWARD SUFFIX]
             ,[ADFM EMP NUM]
             ,[ADFM FULL NAME]
             ,[ORG]
        From [onprc_billing].[ogasynch]
    END

GO
