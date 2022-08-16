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
CREATE PROCEDURE [onprc_ehr].[eIACUC_removeRecords]

  AS
  BEGIN
  	-- SET NOCOUNT ON added to prevent extra result sets from
  	-- interfering with SELECT statements.


      -- Insert statements for procedure here
  	Delete from ehr.protocol
  	where created >= DateAdd(day,-3,GetDate())
  END
