EXEC core.fn_dropifexists 'TempCoV19Interim', 'extScheduler', 'TABLE', NULL;
GO

CREATE TABLE [extscheduler].[TempCoV19Interim](
    [EventId] [varchar](max) NULL,
    [UserName] [nvarchar](1000) NULL,
    [container] [varchar](max) NULL
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO
