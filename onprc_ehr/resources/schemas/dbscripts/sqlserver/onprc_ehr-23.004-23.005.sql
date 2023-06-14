---Create 5-18-2023  R. Blasa  notea; No longer needed


EXEC core.fn_dropifexists 'PrimeProblemListTemp', 'onprc_ehr', 'TABLE', NULL;
GO

EXEC core.fn_dropifexists 'PrimeProblemListMaster', 'onprc_ehr', 'TABLE', NULL;
GO

EXEC core.fn_dropifexists 'p_CaseToPRoblemListupdates', 'onprc_ehr', 'PROCEDURE', NULL;
GO


