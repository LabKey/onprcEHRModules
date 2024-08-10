GO
EXEC core.fn_dropifexists 'ProtocolUpdate', 'onprc_ehr', 'Table';
/****** Object:  Table [ehr].[protocol]    Script Date: 8/9/2024 9:25:25 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [onprc_ehr].[protocolUpdate](
    [protocol] [nvarchar](200) NOT NULL,
    [inves] [nvarchar](200) NULL,
    [approve] [datetime] NULL,
    [description] [text] NULL,
    [createdby] [dbo].[USERID] NOT NULL,
    [created] [datetime] NULL,
    [modifiedby] [dbo].[USERID] NOT NULL,
    [modified] [datetime] NULL,
    [maxanimals] [int] NULL,
    [enddate] [datetime] NULL,
    [title] [nvarchar](1000) NULL,
    [usda_level] [nvarchar](100) NULL,
    [external_id] [nvarchar](200) NULL,
    [project_type] [nvarchar](200) NULL,
    [ibc_approval_required] [bit] NULL,
    [ibc_approval_num] [nvarchar](200) NULL,
    [investigatorId] [int] NULL,
    [last_modification] [datetime] NULL,
    [first_approval] [datetime] NULL,
    [container] [dbo].[ENTITYID] NULL,
    [objectid] [dbo].[ENTITYID] NOT NULL,
    [lastAnnualReview] [datetime] NULL,
    [diCreated] [datetime] NULL,
    [diModified] [datetime] NULL,
    [diCreatedBy] [dbo].[USERID] NULL,
    [diModifiedBy] [dbo].[USERID] NULL,
    [Lsid] [dbo].[LSIDtype] NULL,
    [contacts] [nvarchar](200) NULL,
    [PPQ_Number] nvarchar (255) Null,
    [Protocol_State] nvarchar (200) Null,
    [Template_OID] nvarchar (255) null,
    [Approval_date] Date Null,
    [Annual_Update_Due] Date Null,
    [Three_year_Expiration] Date Null,
    [last_modified] Date Null
    CONSTRAINT [PK_protocolUpdate] PRIMARY KEY CLUSTERED
(
[objectid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO

ALTER TABLE [onprc_ehr].[protocolUpdate] ADD  DEFAULT (newid()) FOR [objectid]
    GO


