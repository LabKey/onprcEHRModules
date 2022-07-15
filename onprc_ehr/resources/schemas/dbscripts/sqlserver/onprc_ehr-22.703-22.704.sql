EXEC core.fn_dropifexists 'Protocol_logs','onprc_ehr','TABLE';
GO


CCREATE TABLE [onprc_ehr].[Protocol_logs](
 	[protocol] [varchar](200) NOT NULL,
 	[inves] [varchar](200) NULL,
 	[approve] [datetime] NULL,
 	[description] [text] NULL,
 	[createdby] [dbo].[USERID] NOT NULL,
 	[created] [datetime] NULL,
 	[modifiedby] [dbo].[USERID] NOT NULL,
 	[modified] [datetime] NULL,
 	[maxanimals] [int] NULL,
 	[enddate] [datetime] NULL,
 	[title] [varchar](1000) NULL,
 	[usda_level] [varchar](100) NULL,
 	[external_id] [varchar](200) NULL,
 	[project_type] [varchar](200) NULL,
 	[ibc_approval_required] [bit] NULL,
 	[ibc_approval_num] [varchar](200) NULL,
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
 	[contacts] [varchar](200) NULL,
  CONSTRAINT [PK_protocol] PRIMARY KEY CLUSTERED
 (
 	[objectid] ASC
 )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
 ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
 GO

 ALTER TABLE [onprc_ehr].[protocol_logs] ADD  DEFAULT (newid()) FOR [objectid]
 GO

