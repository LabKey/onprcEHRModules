EXEC core.fn_dropifexists 'TempCoV19Final', 'extScheduler', 'TABLE', NULL;
    GO
EXEC core.fn_dropifexists 'covid19testing', 'extScheduler', 'TABLE', NULL;
GO

EXEC core.fn_dropifexists 'TempCoV19Interim', 'extScheduler', 'TABLE', NULL;
GO

EXEC core.fn_dropifexists 'vw_Covid19Research', 'extScheduler', 'VIEW', NULL;
GO