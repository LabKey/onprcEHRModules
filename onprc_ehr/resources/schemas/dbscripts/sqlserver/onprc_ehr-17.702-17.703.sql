SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
GO


CREATE TABLE [onprc_ehr].[AvailableBloodVolume](
	[datecreated] [datetime] NULL,
	[id] [nvarchar](32) NULL,
	[gender] [nvarchar](4000) NULL,
	[species] [nvarchar](4000) NULL,
	[yoa] [float] NULL,
	[mostrecentweightdate] [datetime] NULL,
	[weight] [float] NULL,
	[calcmethod] [nvarchar](32) NULL,
	[BCS] [float] NULL,
	[BCSage] [int] NULL,
	[previousdraws] [float] NULL,
	[ABV] [float] NULL,
	[dsrowid] [bigint] NOT NULL
) ON [PRIMARY]
GO
