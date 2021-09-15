EXEC core.fn_dropifexists 'ASB_SpecialInstructions','onprc_ehr','TABLE';
GO

/****** Object:  Table [onprc_ehr].[ASB_SpecialInstructions]   Script Date: 6/8/21 ******/
CREATE TABLE [onprc_ehr].[ASB_SpecialInstructions](
    [RowId]  INT IDENTITY(1,1)NOT NULL,
    [value] [nvarchar](1000) NOT NULL,
    [remarks] [nvarchar](2000) NULL,
    [dateDisabled] [datetime] NULL,
    [created] [datetime] NULL,
    [createdBy] [int] NULL,
    [modified] [datetime] NULL,
    [modifiedBy] [int] NULL

    CONSTRAINT pk_ASB_SpecialInstructions PRIMARY KEY (RowId)
    )

    GO