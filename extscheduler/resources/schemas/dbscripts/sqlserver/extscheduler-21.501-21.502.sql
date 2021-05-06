EXEC core.fn_dropifexists 'covid19testing', 'extScheduler', 'TABLE', NULL;
GO



CREATE TABLE extscheduler.covid19testing](
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
    [ComplianceUpdated] [bit] NULL)