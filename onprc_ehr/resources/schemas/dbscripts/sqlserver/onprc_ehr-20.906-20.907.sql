EXEC core.fn_dropifexists 'PMIC_Reference_Data','onprc_ehr','TABLE';
    GO

/****** Object:  Table [onprc_ehr].[PMIC_Reference_Data]    Script Date: 2/12/2020 ******/
CREATE TABLE [onprc_ehr].[PMIC_Reference_Data](
    [RowId]  INT IDENTITY(1,1)NOT NULL,
    [value] [nvarchar](1000) NULL,
    [name] [nvarchar](1000) NULL,
    [remark] [nvarchar](4000) NULL,
    [dateDisabled] [datetime] NULL,
    [created] [datetime] NULL,
    [createdBy] [int] NULL,
    [modified] [datetime] NULL,
    [modifiedBy] [int] NULL

    CONSTRAINT pk_PMIC_Reference_Data PRIMARY KEY (RowId)
    )

    GO
