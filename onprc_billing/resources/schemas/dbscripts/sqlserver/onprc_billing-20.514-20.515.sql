/****** Object:  StoredProcedure [onprc_billing].[oga_InsertRecords]    Script Date: 5/21/2020 5:43:28 AM ******/
/*****Update 2020-05-21 to handle Investigator and FA Ids in Prime*******/

ALTER PROCEDURE [onprc_billing].[oga_InsertRecords]

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
             ,Case
                  when [ALIAS ENABLED FLAG] =  0 then 'n'
                  when [ALIAS ENABLED FLAG] = 1 then 'y'
            End  as AliasEndabled

             --,[ALIAS ENABLED FLAG]
             ,[OGA PROJECT NUMBER]
             ,[OGA AWARD NUMBER]
             ,[AGENCY AWARD NUMBER]
             ,Case
                  When (Select rowID from [onprc_ehr].[investigators] where [PI EMP NUM] = employeeID and datedisabled is null) is not null
                      Then (Select rowID from [onprc_ehr].[investigators] where [PI EMP NUM] = employeeID and datedisabled is null)
                  Else Null
            End as InvestigatorID
             -- ,[PI EMP NUM]
             -- ,(Select rowID from [onprc_ehr].[investigators] where [PI EMP NUM] = employeeID and datedisabled is null) as PILastName
             -- [PI EMP NUM]
             ,[PI FULL NAME]
             ,(Select rowid from [onprc_billing].[fiscalAuthorities] where [PDFM EMP NUM] = employeeID and active = 1) as fiscalAuthority
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

        Update [Labkey].[onprc_billing].[aliases]
         Set aliasEnabled = 'n'
         --where AliasEnabled is null
         --Select * from [Labkey].[onprc_billing].[aliases]
         where ((budgetEndDate < GetDate() or budgetEndDate is null) or category != 'OHSU GL')

    END


