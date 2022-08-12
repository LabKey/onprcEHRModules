-- This stored procedure was incorrectly named and placed in the wrong schema when created in onprc_ehr-18.10-20.101.sql.
-- It's also unused, so just drop it.
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND object_id = OBJECT_ID('[onprc_ehr].[insertToEhr_Protocol]'))
    DROP PROCEDURE [onprc_ehr].[insertToEhr_Protocol]
SET ANSI_NULLS ON
GO

  SET QUOTED_IDENTIFIER ON
  GO
  -- =============================================
  -- Author:		gary Jones
  -- Create date: 2022/06/20
  -- Description:	Process to remove records created in eIACUC from protocol dataset
  -- =============================================
CREATE PROCEDURE [onprc_ehr].[insertToEhr_Protocol]


  AS
INSERT INTO [ehr].[protocol]
           ([protocol]
           ,[investigatorId]
           ,[approve]
           .[template_oid]
		   ,createdBy
		   ,modifiedby
           ,[title]
           ,[usda_level]
           ,[external_id]
           ,[protocol_state]
		   ,[last_modification]
		   ,enddate
		   ,container)



     SELECT
	   [Protocol_ID]
	   (Select rowid from onprc_ehr.investigators where employeeID = PI_ID and datedisabled is null)PI_ID
	  ,[Approval_Date]
      ,[Template_OID]
	  ,'1011'
	  ,'1011'
      ,[Protocol_Title]
      ,[USDA_Level]
	  ,Protocol_id
	  ,[PROTOCOL_State]
      ,last_modified
	  , Case when protocol_state = 'expired' then last_modified
		When protocol_state = 'terminated' then last_modified
		else Null
		End as enddate
		,'CD17027B-C55F-102F-9907-5107380A54BE'


  FROM [onprc_ehr].[eIACUC_PRIME_VIEW_PROTOCOLS]
  where (Protocol_state <> 'Withdrawn' and Len(PI_ID) > 3)