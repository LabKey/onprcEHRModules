/*
-- Created: 9-10-2026   G. Jones   Process to remove  stored procedure that are no longer needed
*  Drop extscheduler.cov19ScheduleProcessDCM
-  Drop onprc_ehr.etl.Step1eIACUCtoPRIMEProcessing
- -Drop onprc_billing.AliasCleanup202004
- -Drop onprc_billing.AnnualRateChangeProcess
-  Drop onprc_ehr.etl1_eIACUCtoPublicAction
-   Drop onprc_ehr.etl2_update_ehrProtocol
-   Drop onprc_ehr.etl3_insertToEhr_Protocol

*/
-- Drop extscheduler.cov19ScheduleProcessDCM was part of work for Covid 19
EXEC core.fn_dropifexists 'cov19ScheduleProcessDCM' ,'extscheduler','PROCEDURE';


-- Drop was updated with a new name
EXEC core.fn_dropifexists 'AliasCleanup202004' ,'onprc_billing','PROCEDURE';


-- Drop onprc_billing.AnnualRateChangeProcess new script created that update code
EXEC core.fn_dropifexists 'AnnualRateChangeProcess','onprc_billing','PROCEDURE';

-- Drop extscheduler.cov19ScheduleProcessDCM was part of work for Covid 19

EXEC core.fn_dropifexists 'etl1_eIACUCtoPublicAction','onprc_ehr','PROCEDURE';



-- Drop onprc_ehr.etl3_insertToEhr_Protocol was part of original work on eIACUC
EXEC core.fn_dropifexists 'etl2_update_ehrProtocol' ,'onprc_ehr','PROCEDURE';


-- Drop onprc_ehr.etl3_insertToEhr_Protocol was part of original work on eIACUC
EXEC core.fn_dropifexists 'etl3_insertToEhr_Protocol' ,'onprc_ehr','PROCEDURE';









