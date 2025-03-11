

CREATE INDEX IX_completiondates_trainer ON ehr_compliancedb.completiondates(trainer);
GO

-- Author:	R. Blasa
-- Created: 9-16-2024

/*
**
** 	Created by
**      Blasa  		9-16-2024               Storedprocedure to update Compliance Access contaimer values
**
**
**
*/

CREATE Procedure onprc_ehr_compliancedb.[p_ComplianceAccesscontainerUpdate]


AS



BEGIN

          ------ Update container value and include as part of the main Compliance module

If exists(Select * from  ehr_Compliancedb.CompletionDates ss where ss.container =  '47F00C3F-5691-103D-8866-41AD310B2640' )
BEGIN

  Update ss
    set ss.container =   'CD170458-C55F-102F-9907-5107380A54BE'    ----Compliance folder on Prime Production

   from  ehr_Compliancedb.CompletionDates ss
    Where ss.container = 'F1C05E2D-618D-103D-ABC9-9814909BFFCD'    ---Compliance Access folder on Prime Production

                If @@Error <> 0
                     GoTo Err_Proc

 END

ELSE             ------ No new entries exit
  BEGIN

    GOTO No_Records

  END




No_Records:

 RETURN 0


Err_Proc:
                    -------Error Generated, Transfer process stopped
	RETURN 1


END

GO