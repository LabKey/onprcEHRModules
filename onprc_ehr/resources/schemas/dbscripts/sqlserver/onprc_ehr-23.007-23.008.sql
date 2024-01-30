/****** Add MPA Clinical remarks: By Kolli******/
/*
 Created 1 temp table to store the clinical remarks records.
 The stored proc manages the addition and deleting clinical remarks data from the temp table
 at the time of execution via ETL process.
 */
EXEC core.fn_dropifexists 'Temp_ClnRemarks','onprc_ehr','TABLE';
GO

-- Create the temp table
CREATE TABLE onprc_ehr.Temp_ClnRemarks
(
    date datetime,
    qcstate int,
    participantid nvarchar(32),
    project int,
    remark nvarchar(4000) ,
    description nvarchar(4000) ,
    performedby nvarchar(4000) ,
    category nvarchar(4000) ,
    taskid nvarchar(4000)
)
;

GO


-- Create the stored proc here
/****** Object:  StoredProcedure [onprc_ehr].[MPA_ClnRemarkAddition]    Script Date: 1/25/2024 *****/

-- =============================================
 -- Author: Lakshmi Kolli
 -- Create date: 1/25/2023
 -- Description: This procedure identifies if an animal received an MPA injection
 -- and inserts a clinical remark into animal's record.
 -- =============================================

 CREATE PROCEDURE [onprc_ehr].[MPA_ClnRemarkAddition]
 AS

 DECLARE
    @MPACount Int,
	@taskId	  Int

BEGIN
    --Delete all rows from the temp_Drug table
    Delete From Labkey_public.onprc_ehr.Temp_ClnRemarks

    --Check if the MPA injection, E-85760 was administered today
    Select @MPACount = COUNT(*) From studyDataset.c6d178_drug
    Where code = 'E-85760' And CONVERT(DATE, date) = CONVERT(DATE, GETDATE()) And qcstate = 18

  --Found entries, so, enter the clinical remark for that
    If @MPACount > 0
    Begin

        -- Create a TaskId
        -- Get the rowId which is the taskId
        Insert Into [ehr].[tasks]
        (taskid, category, title, formtype, qcstate, assignedto, duedate, createdby, created,
        container, modifiedby, modified, description, datecompleted)
        Values
        (NEWID(), 'Task', 'Bulk Clinical Entry', 'Bulk Clinical Entry', 18, 1003, GETDATE(), 1003, GETDATE(),
        'CD17027B-C55F-102F-9907-5107380A54BE', 1003, GETDATE(), 'Created by the ETL process', GETDATE())

        --Get the latest taskId
        Select Top 1 @taskId = rowId From ehr.tasks
        Where formType = 'Bulk Clinical Entry' And qcstate = 18 And createdby = 1003
        And CONVERT(DATE, created) = CONVERT(DATE, GETDATE()) Order by rowId desc

        --Insert the clinical remark into the clinical remarks
        -- Get all the Animals who had MPA injection today in studyDataset.c6d178_drug
        -- and INSERT the data into the studyDataset.c6d185_clinremarks table
        Insert Into labkey_LK_public.onprc_ehr.Temp_ClnRemarks (
        date, qcstate, participantid, project, remark, description, performedby, category, taskid
        )
        Select
            GETDATE(), 18, participantid, project, 'Remark entered by the ETL process',
            'P1: MPA injection administered', 1003, 'Clinical', '662095'
        From  studyDataset.c6d178_drug
        Where code = 'E-85760' And CONVERT(DATE, date) = CONVERT(DATE, GETDATE()) And qcstate = 18

    End

END

GO
