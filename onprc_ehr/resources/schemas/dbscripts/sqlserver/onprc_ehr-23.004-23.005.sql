---Create 5-2023-08-15 jonesga

EXEC core.fn_dropifexists 'PrimeProblemListTemp', 'onprc_ehr', 'TABLE', NULL;
GO

EXEC core.fn_dropifexists 'PrimeProblemListMaster', 'onprc_ehr', 'TABLE', NULL;
GO

EXEC core.fn_dropifexists 'p_CaseToPRoblemListupdates', 'onprc_ehr', 'PROCEDURE', NULL;
GO


