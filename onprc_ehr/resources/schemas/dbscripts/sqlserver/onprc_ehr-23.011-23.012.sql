-- Alter the stored proc
/****** Object:  StoredProcedure [onprc_ehr].[MPA_ClnRemarkAddition]  Script Date: 5/17/2024 *****/
-- =================================================================================
-- Author: Lakshmi Kolli
-- Create date: 5/17/2024
-- Description: Altering the procedure with the new ONPRC email address
-- =================================================================================

ALTER PROCEDURE [onprc_ehr].[MPA_ClnRemarkAddition]
AS

DECLARE
@MPACount       Int,
@taskId	        nvarchar(4000),
@displayName    nvarchar(250)

BEGIN
    --Delete all rows from the temp_Drug table
    Delete From onprc_ehr.Temp_ClnRemarks

    --Check if the MPA injection E-85760 was administered today
    Select @MPACount = COUNT(*) From studyDataset.c6d178_drug
    Where code = 'E-85760' And CONVERT(DATE, date) = CONVERT(DATE, GETDATE()) And qcstate = 18

    --Found entries, so, enter the clinical remarks now
    If @MPACount > 0
    Begin
        -- Get the displayName for user: onprc-is from core.users table
        Select @displayName = displayName from core.users where userid = 1003

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
        Select GETDATE(), 18, participantid, project, 'Remark entered by the ETL process', 'MPA injection administered', @displayName, 'Clinical', @taskId, 1003, 1003
        From studyDataset.c6d178_drug
        Where code = 'E-85760' And CONVERT(DATE, date) = CONVERT(DATE, GETDATE()) And qcstate = 18
    End
END

GO