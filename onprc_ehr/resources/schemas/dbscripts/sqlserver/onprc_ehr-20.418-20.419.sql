EXEC core.fn_dropifexists 'IPC_Reference_Data','onprc_ehr','TABLE';
GO

/****** Object:  Table [onprc_ehr].[IPC_Reference_Data]    Script Date: 4/27/2020 ******/
CREATE TABLE [onprc_ehr].[IPC_Reference_Data](
    [rowId]  INT IDENTITY(1,1)NOT NULL,
    [value] [nvarchar](1000) NULL,
    [name] [nvarchar](1000) NULL,
    [remark] [nvarchar](4000) NULL,
    [dateDisabled] [datetime] NULL,
    [created] [datetime] NULL,
    [createdBy] [int] NULL,
    [modified] [datetime] NULL,
    [modifiedBy] [int] NULL

    CONSTRAINT pk_IPC_Reference_Data PRIMARY KEY (rowId)
    )