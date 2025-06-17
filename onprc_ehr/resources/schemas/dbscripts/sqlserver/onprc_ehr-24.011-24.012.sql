/****** Object:  StoredProcedure [audit].[InitializeArchiveEnvironment]    Script Date: 6/17/2025 1:38:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [audit].[InitializeArchiveEnvironment]
    @SourceDB NVARCHAR(128),
    @DestDB NVARCHAR(128),
    @SchemaName NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = @SourceDB)
        THROW 50000, 'Source database does not exist.', 1;

    IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = @DestDB)
        THROW 50000, 'Destination database does not exist.', 1;

    DECLARE @SQL NVARCHAR(MAX) = '
    USE ' + QUOTENAME(@DestDB) + ';
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = ''' + @SchemaName + ''')
        EXEC(''CREATE SCHEMA ' + QUOTENAME(@SchemaName) + ''');';

EXEC sp_executesql @SQL;

    SET @SQL = '
    USE ' + QUOTENAME(@DestDB) + ';
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''ArchiveAuditLog'')
    BEGIN
        CREATE TABLE dbo.ArchiveAuditLog (
            LogID INT IDENTITY(1,1),
            TableName NVARCHAR(128),
            Operation NVARCHAR(50),
            StartTime DATETIME,
            EndTime DATETIME,
            Status NVARCHAR(50),
            RecordsProcessed INT,
            ErrorMessage NVARCHAR(MAX),
            RetentionYears INT
        );
    END';

EXEC sp_executesql @SQL;
END;
