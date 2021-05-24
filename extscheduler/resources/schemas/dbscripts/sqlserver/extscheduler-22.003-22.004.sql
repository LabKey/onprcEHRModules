ALTER TABLE extscheduler.Events ADD [EmployeeID] [nvarchar](4000) NULL;
ALTER TABLE extscheduler.Events ADD [Recorded] [smalldatetime] NULL;
ALTER TABLE extscheduler.Events ADD	[RecordedBy] [int] NULL;
ALTER TABLE extscheduler.Events ADD	[ComplianceUpdated] [bit] NULL;
ALTER TABLE extscheduler.Events ADD [DateCompleted] [smalldatetime] NULL