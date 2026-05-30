/*
 * Copyright (c) 2023-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EXEC core.fn_dropifexists 'TempCoV19Final', 'extScheduler', 'TABLE', NULL;
    GO
EXEC core.fn_dropifexists 'covid19testing', 'extScheduler', 'TABLE', NULL;
GO

EXEC core.fn_dropifexists 'tempscheduler', 'extScheduler', 'TABLE', NULL;
GO

EXEC core.fn_dropifexists 'TempCoV19Interim', 'extScheduler', 'TABLE', NULL;
GO

EXEC core.fn_dropifexists 'vw_Covid19Research', 'extScheduler', 'VIEW', NULL;
GO

EXEC core.fn_dropifexists 'vw_covid19dcmschedule', 'extScheduler', 'VIEW', NULL;
GO

EXEC core.fn_dropifexists 'vw_Covid19DCMDaily', 'extScheduler', 'VIEW', NULL;
GO
