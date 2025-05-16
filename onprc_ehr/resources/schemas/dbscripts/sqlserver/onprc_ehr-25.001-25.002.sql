--This is the log table for actions compelted by the Stored Procedure for Audit Log Maintenance
--Revision to Add check for exists
--Update 2025-05-15 For Testing F For 1 Year
EXEC core.fn_dropifexists 'ArchiveAuditLog','dbo','TABLE';
CREATE TABLE [dbo].[ArchiveAuditLog](
    [LogID] [int] IDENTITY(1,1) NOT NULL,
    TableName NVARCHAR(128) NOT NULL,
    Operation NVARCHAR(50) NOT NULL,
    StartTime DATETIME NOT NULL,
    EndTime DATETIME NULL,
    Status NVARCHAR(50) NULL,
    RecordsProcessed INT NULL,
    ErrorMessage NVARCHAR(MAX) NULL,
    RetentionYears INT NULL