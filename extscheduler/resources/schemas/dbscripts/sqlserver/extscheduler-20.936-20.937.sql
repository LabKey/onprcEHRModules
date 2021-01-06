EXEC core.fn_dropifexists 'TempCoV19Final', 'extScheduler', 'TABLE', NULL;
    GO

CREATE TABLE [extscheduler].[TempCoV19Final](
    [container] [uniqueidentifier] NOT NULL,
    [UserName] [nvarchar](4000) NULL,
    [UserID] [int] NULL,
    [EventID] [int] NULL,
    [StartDate] [smalldatetime] NULL,
    [EmployeeID] [nvarchar](4000) NULL,
    [Created] [smalldatetime] NULL
    ) ON [PRIMARY]
    GO
