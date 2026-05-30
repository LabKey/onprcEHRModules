/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EXEC core.fn_dropifexists 'TempScheduler', 'extScheduler', 'TABLE', NULL;
GO

CREATE TABLE [extscheduler].[TempScheduler](
    [Searchkey] [int] IDENTITY(100,1) NOT NULL,
    [usernames] [varchar](500) NULL,
    [EventId] [varchar](max) NULL,
    [StartDate] [smalldatetime] NULL,
    [created] [smalldatetime] NULL
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO
