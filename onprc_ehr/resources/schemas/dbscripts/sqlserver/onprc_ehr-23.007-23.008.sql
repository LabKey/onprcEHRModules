-- =================================================================================================
-- Add MPA Clinical remarks: By, Lakshmi Kolli
-- Created on: 1/25/2024
/* Description: Created 1 temp table to store the clinical remarks records.
 The stored proc manages the addition and deleting clinical remarks data from the temp table
 at the time of execution via ETL process.
 */
-- =================================================================================================

--Drop table if exists
EXEC core.fn_dropifexists 'Temp_ClnRemarks','onprc_ehr','TABLE';
--Drop Stored proc if exists
EXEC core.fn_dropifexists '[onprc_ehr].[MPA_ClnRemarkAddition]', 'onprc_ehr', 'PROCEDURE';
GO

-- Create the temp table
CREATE TABLE onprc_ehr.Temp_ClnRemarks
(
    date datetime,
    qcstate int,
    participantid nvarchar(32),
    project int,
    remark nvarchar(250) ,
    p nvarchar(250) ,
    performedby nvarchar(250) ,
    category nvarchar(250) ,
    taskid nvarchar(4000),
    createdby int,
    modifiedby int
)
;

GO

-- Create the stored proc
/****** Object:  StoredProcedure [onprc_ehr].[MPA_ClnRemarkAddition]    Script Date: 1/25/2024 *****/
-- =================================================================================
 -- Author: Lakshmi Kolli
 -- Create date: 1/25/2024
 -- Description: This procedure identifies if an animal received an MPA injection
 -- and inserts a clinical remark into animal's record.
-- =================================================================================

CREATE PROCEDURE [onprc_ehr].[MPA_ClnRemarkAddition]
AS

DECLARE
@MPACount Int,
	@taskId	  nvarchar(4000)

BEGIN
    --Delete all rows from the temp_Drug table
Delete From onprc_ehr.Temp_ClnRemarks

--Check if the MPA injection, E-85760 was administered today
Select @MPACount = COUNT(*)
From studyDataset.c6d178_drug
Where code = 'E-85760' And CONVERT(DATE, date) = CONVERT(DATE, GETDATE()) And qcstate = 18

  --Found entries, so, enter the clinical remarks now
    If @MPACount > 0
Begin
        -- Create a Task entry in ehr.tasks table
        Set @taskid = NEWID() -- creating taskid
        Insert Into ehr.tasks
        (taskid, category, title, formtype, qcstate, assignedto, duedate, createdby, created,
         container, modifiedby, modified, description, datecompleted)
        Values
        (@taskid, 'Task', 'Bulk Clinical Entry', 'Bulk Clinical Entry', 18, 1003, GETDATE(), 1003, GETDATE(),
         'CD17027B-C55F-102F-9907-5107380A54BE', 1003, GETDATE(), 'Created by the ETL process', GETDATE())

        --Insert the clinical remark into the temp clinical remarks table.
        /* Get all the Animals who had MPA injection today from studyDataset.c6d178_drug
        and INSERT the data into the studyDataset.c6d185_clinremarks table */
        Insert Into onprc_ehr.Temp_ClnRemarks (
        date, qcstate, participantid, project, remark, p, performedby, category, taskid, createdby, modifiedby
        )
Select GETDATE(), 18, participantid, project, 'Remark entered by the ETL process', 'P1 - MPA injection administered', 'onprcitsupport@ohsu.edu', 'Clinical', @taskId, 1003, 1003
From studyDataset.c6d178_drug
Where code = 'E-85760' And CONVERT(DATE, date) = CONVERT(DATE, GETDATE()) And qcstate = 18
End

END

GO
