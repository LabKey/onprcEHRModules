EXEC core.fn_dropifexists 'ogaSynch','onprc_billing','TABLE';
GO

CREATE TABLE [onprc_billing].[ogasynch](
	[lastIndexed] [datetime] NULL,
	[modifiedBy] [int] NULL,
	[container] [dbo].[ENTITYID] NOT NULL,
	[modified] [datetime] NULL,
	[created] [datetime] NULL,
	[entityId] [dbo].[ENTITYID] NOT NULL,
	[createdBy] [int] NULL,
	[ADFM EMP NUM] [int] NULL,
	[ADFM FULL NAME] [nvarchar](4000) NULL,
	[ADFM LAST NAME] [nvarchar](4000) NULL,
	[ADFM FIRST NAME] [nvarchar](4000) NULL,
	[PI EMP NUM] [int] NULL,
	[PI FULL NAME] [nvarchar](4000) NULL,
	[PI LAST NAME] [nvarchar](4000) NULL,
	[PI FIRST NAME] [nvarchar](4000) NULL,
	[PDFM EMP NUM] [int] NULL,
	[PDFM FULL NAME] [nvarchar](4000) NULL,
	[PDFM LAST NAME] [nvarchar](4000) NULL,
	[PDFM FIRST NAME] [nvarchar](4000) NULL,
	[AGENCY AWARD NUMBER] [nvarchar](4000) NULL,
	[OGA AWARD NUMBER] [nvarchar](4000) NULL,
	[OGA AWARD TYPE] [nvarchar](4000) NULL,
	[OGA PROJECT NUMBER] [nvarchar](4000) NULL,
	[ALIAS] [int] NULL,
	[ALIAS ENABLED FLAG] [bit] NULL,
	[ALIAS ENABLED FLAG_MVIndicator] [nvarchar](50) NULL,
	[PROJECT DESCRIPTION] [nvarchar](4000) NULL,
	[APPLICATION TYPE] [int] NULL,
	[ACTIVITY TYPE] [nvarchar](4000) NULL,
	[AWARD NUMBER] [nvarchar](4000) NULL,
	[AWARD SUFFIX] [nvarchar](4000) NULL,
	[ORG] [nvarchar](4000) NULL,
	[CURRENT BUDGET START DATE] [datetime] NULL,
	[CURRENT BUDGET END DATE] [datetime] NULL,
	[PROJECT TITLE] [nvarchar](4000) NULL,
	[PPQ CODE] [nvarchar](4000) NULL,
	[PPQ DATE] [datetime] NULL,
	[IACUC NUMBER] [nvarchar](4000) NULL,
	[AWARD STATUS] [nvarchar](4000) NULL,
	[PROJECT STATUS] [nvarchar](4000) NULL,
	[AWARD ID] [int] NULL,
	[PROJECT ID] [int] NULL,
	[BURDEN SCHEDULE] [nvarchar](4000) NULL,
	[BURDEN RATE] [float] NULL,
	[faRate] [float] NULL,
	[Key] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO