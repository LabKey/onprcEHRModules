EXEC core.fn_dropifexists 'TempCoV19Interim', 'extScheduler', 'TABLE', NULL;
GO

/****** Object:  Table [extscheduler].[TempScheduler]
  ONCE TESTED CHAN GE TO labkey_public
  Script Date: 10/29/2020 8:19:18 AM ******/

CREATE TABLE [extscheduler].[TempCoV19Interim](
    [EventId] [varchar](max) NULL,
    [UserName] [nvarchar](1000) NULL,
    [container] [varchar](max) NULL,
    [notes] nvarchar(100) null
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO
