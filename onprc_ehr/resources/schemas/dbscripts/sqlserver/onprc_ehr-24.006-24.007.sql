SET ANSI_NULLS ON
GO
EXEC core.fn_dropifexists 'eIACUCToPrimeProtocolStatus', 'onprc_ehr', 'TABLE';
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [onprc_ehr].eIACUCToPrimeProtocolStatus(
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
    [baseProtocol] [varchar](75) NULL,
    [RenewalNumber] [varchar](75) NULL,
    [LatestRenewal] [bit] NULL
    ) ON [PRIMARY]
    GO
