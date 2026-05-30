/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EXEC core.fn_dropifexists 'TempCoV19Interim', 'extScheduler', 'TABLE', NULL;
GO

CREATE TABLE [extscheduler].[TempCoV19Interim](
    [EventId] [varchar](max) NULL,
    [UserName] [nvarchar](1000) NULL,
    [container] [varchar](max) NULL
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO
