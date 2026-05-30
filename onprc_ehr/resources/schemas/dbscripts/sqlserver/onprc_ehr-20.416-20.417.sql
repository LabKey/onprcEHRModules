/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EXEC core.fn_dropifexists 'StudyDetails_Reference_Data','onprc_ehr','TABLE';
GO

/****** Object:  Table [onprc_ehr].[StudyDetails_Reference_Data]    Script Date: 2/20/2020 ******/

CREATE TABLE [onprc_ehr].[StudyDetails_Reference_Data](
    [rowId]  INT IDENTITY(1,1)NOT NULL,
    [value] [nvarchar](1000) NULL,
    [name] [nvarchar](1000) NULL,
    [remark] [nvarchar](4000) NULL,
    [sort_order] INT NULL,
    [dateDisabled] [datetime] NULL,
    [created] [datetime] NULL,
    [createdBy] [int] NULL,
    [modified] [datetime] NULL,
    [modifiedBy] [int] NULL

    CONSTRAINT pk_StudyDetails_Reference_Data PRIMARY KEY (rowId)
    )
GO