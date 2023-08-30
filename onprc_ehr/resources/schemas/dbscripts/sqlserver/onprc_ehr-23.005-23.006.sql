

EXEC core.fn_dropifexists 'p_CageStatusupdates', 'onprc_ehr', 'PROCEDURE', NULL;
GO

-- Author:	R. Blasa
-- Created: 8-30-2023
-- Description:	Stored procedure program to allow cage status settings to be updated by default to "Normal".


CREATE Procedure [onprc_ehr].[p_CageStatusupdates]

AS

DECLARE


BEGIN

    --- Set Cage status to Normal                       )

     Update ehr_lookups.cage
          Set status = 'Normal'
         Where status is null


    If @@Error <> 0
	  GoTo Err_Proc


 RETURN 0


Err_Proc:
                    -------Error Generated
	RETURN 1


END

GO