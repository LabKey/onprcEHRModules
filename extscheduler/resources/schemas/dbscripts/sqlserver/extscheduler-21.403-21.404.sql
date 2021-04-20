
/****** Object:  Table [list].[c10437d746_covid19testing]    Script Date: 9/16/2020 9:19:28 AM ******/
EXEC core.fn_dropifexists 'Covid19Testing', 'extScheduler', 'TABLE', NULL;
GO

CREATE TABLE [extScheduler].[Covid19Testing](
    [container] [dbo].[ENTITYID] NOT NULL,
    [entityId] [dbo].[ENTITYID] NOT NULL,
    [lastIndexed] [datetime] NULL,
    [createdBy] [int] NULL,
    [modified] [datetime] NULL,
    [modifiedBy] [int] NULL,
    [created] [datetime] NULL,
    [Key] [int] IDENTITY(1,1) NOT NULL,
    [SchedulerID] [int] NULL,
    [ResourceID] [int] NULL,
    [UserName] [nvarchar](4000) NULL,
    [UserID] [int] NULL,
    [EmployeeID] [nvarchar](4000) NULL,
    [ScheduledDate] [datetime] NULL,
    [ScheduledTime] [datetime] NULL,
    [Create] [datetime] NULL,
    [SampleDate] [nvarchar](4000) NULL,
    [CreatedB] [nvarchar](4000) NULL,
    [ComplianceUpdated] [bit] NULL,
    CONSTRAINT [covid19testing_pk] PRIMARY KEY CLUSTERED
(
[Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO

