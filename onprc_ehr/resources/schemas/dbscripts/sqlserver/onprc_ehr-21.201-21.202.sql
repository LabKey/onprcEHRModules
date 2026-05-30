/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EXEC core.fn_dropifexists 'BSUageclass','onprc_ehr','TABLE';
GO


CREATE TABLE [onprc_ehr].[BSUageclass]
(
    [rowId]  INT IDENTITY(1,1)NOT NULL,
    label varchar(255) NULL,
    species varchar(255) NULL,
    gender varchar(5) NULL,
    ageclass INT NULL,
    min [float] NULL,
    max [float] NULL,
    [sort_order] INT NULL,
    [dateDisabled] [datetime] NULL,

    CONSTRAINT PK_bsuageclass PRIMARY KEY (rowId)

    )
    GO
