-- This stored procedure was incorrectly named and placed in the wrong schema when created in onprc_ehr-18.10-20.101.sql.
-- It's also unused, so just drop it.
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND object_id = OBJECT_ID('[dbo].[onprc_ehr.etlStep1eIACUCtoPRIMEProcessing]'))
    DROP PROCEDURE [dbo].[onprc_ehr.etlStep1eIACUCtoPRIMEProcessing]
