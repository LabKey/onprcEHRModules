/*Corrected to remove sql script not related to this module.*/
EXEC core.fn_dropifexists 'eIACUC_Data','onprc_billing','TABLE';
GO



/****** Object:  Table [onprc_ehr].[[eIACUC_Data]]    Script Date: 11/30/2023 7:25:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [onprc_billing].[eIACUC_Data](
    [rowid] [int] IDENTITY(1,1) NOT NULL,
    [Protocol_ID] [varchar](255) NOT NULL,
    [Template_OID] [varchar](32) NULL,
    [Protocol_OID] [varchar](255) NULL,
    [Protocol_Title] [varchar](255) NULL,
    [PI_ID] [varchar](255) NULL,
    [PI_First_Name] [varchar](255) NULL,
    [PI_Last_Name] [varchar](255) NULL,
    [PI_Email] [varchar](255) NULL,
    [PI_Phone] [varchar](255) NULL,
    [USDA_Level] [varchar](255) NULL,
    [Approval_Date] [datetime] NULL,
    [Annual_Update_Due] [datetime] NULL,
    [Three_year_Expiration] [datetime] NULL,
    [Last_Modified] [datetime] NULL,
    [createdby] [int] NULL,
    [created] [datetime] NULL,
    [modifiedby] [int] NULL,
    [modified] [datetime] NULL,
    [PROTOCOL_State] [varchar](250) NULL,
    [PPQ_Numbers] [varchar](255) NULL,
    [Description] [varchar](255) NULL,
    [RevisionNumber] [varchar](255) NULL,
    [Protocol][varchar](255) NULL
    ) ON [PRIMARY]
    GO


