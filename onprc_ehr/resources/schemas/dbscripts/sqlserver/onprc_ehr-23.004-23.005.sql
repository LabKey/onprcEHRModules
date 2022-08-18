-- This stored procedure was incorrectly named and placed in the wrong schema when created in onprc_ehr-18.10-20.101.sql.
-- It's also unused, so just drop it.
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND object_id = OBJECT_ID('[onprc_ehr].[eIACUC_removeRecords]'))
    DROP PROCEDURE [onprc_ehr].[eIACUC_removeRecords]
SET ANSI_NULLS ON
GO

  SET QUOTED_IDENTIFIER ON
  GO
  -- =============================================
  -- Author:		gary Jones
  -- Create date: 2022/06/20
  -- Description:	Process to remove records created in eIACUC from protocol dataset
  -- =============================================
ALTER PROCEDURE [onprc_ehr].[eIACUC_removeRecords]

  AS
  BEGIN
  	Delete from ehr.protocol
  	where project_type like '%Source'
  END

