--This is the log table for actions compelted by the Stored Procedure for Audit Log Maintenance
--Revision to Add check for exists
/*UPdat 2025-05-14*/
EXEC core.fn_dropifexists 'ArchiveAuditLog','dbo','TABLE';
CREATE TABLE [dbo].[ArchiveAuditLog](
    [LogID] [int] IDENTITY(1,1) NOT NULL,
    [TableName] [nvarchar](128) NOT NULL,
    [Operation] [nvarchar](50) NOT NULL,
    [StartTime] [datetime] NOT NULL,
    [EndTime] [datetime] NULL,
    [Status] [nvarchar](50) NOT NULL,
    [ErrorMessage] [nvarchar](max) NULL,
    [RetentionYears] [int] NULL,
    [RecordsProcessed] [int] NULL)