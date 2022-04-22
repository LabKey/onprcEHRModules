--20220406 update of SP for insert
EXEC core.fn_dropifexists 'oga_InsertRecords', 'onprc_billing', 'PROCEDURE'
GO

CREATE PROCEDURE [onprc_billing].[oga_InsertRecords] AS
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
,[OriginatingAgencyAwardNum]
)
SELECT
    [Alias],
    Case
        when [ALIAS ENABLED FLAG] =  1 then 'y'
        when [ALIAS ENABLED FLAG] =  0 then 'n'
        End as AliasEnabled

        ,[OGA PROJECT NUMBER]
             ,[OGA AWARD NUMBER]
             ,[AGENCY AWARD NUMBER]
             ,i.rowId
			--End as [PI EMP NUM]
			 ,[PI FULL NAME]
			 ,f.rowid
			 --,[PDFM EMP NUM]
            ,'0F8BB08E-E4BF-102F-B89B-5107380A5B61'
             ,1003
             ,GetDate()
             ,'OGA'
             ,[farate]
             ,[BURDEN SCHEDULE]
             ,[CURRENT BUDGET START DATE]
             ,[CURRENT BUDGET END DATE]
             ,[PROJECT TITLE]
             ,[PROJECT DESCRIPTION]
             ,[PROJECT STATUS]
             ,[OGA AWARD TYPE]
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
             ,[ORIGINATING_AGENCY_AWARD_NUM]
        From [onprc_billing].[ogasynch] o
		left outer join [onprc_ehr].investigators i on o.[PI EMP NUM] = i.employeeid and i.datedisabled is Null
		left outer join onprc_billing.fiscalAuthorities f on f.employeeId = o.[PDFM EMP NUM] and f.active = 'true';

END
GO
