/****** Object:  StoredProcedure [audit].[ArchiveAuditTable]
*Update to puish 2025-0618
Script Date: 6/17/2025 1:40:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [audit].[ArchiveAuditTable]


AS
BEGIN
    SET NOCOUNT ON;
	DECLARE
@SourceDB NVARCHAR(128) = 'Labkey_next_GJ',
    @DestDB NVARCHAR(128) = 'primeaudit_sandbox',
    @SchemaName NVARCHAR(128)= 'audit',
    @TableName NVARCHAR(128),
	@RetentionYears INT = 10

    DECLARE @CutoffDate DATETIME;
    SET @CutoffDate = DATEADD(YEAR, -@RetentionYears, GETDATE());

    DECLARE @LogID INT;

INSERT INTO [primeaudit_sandbox].dbo.ArchiveAuditLog
(TableName, Operation, StartTime, Status, RetentionYears)
VALUES (@TableName, 'Archive', GETDATE(), 'Started', @RetentionYears);

SET @LogID = SCOPE_IDENTITY();

BEGIN TRY
        DECLARE @FullSource NVARCHAR(MAX) = QUOTENAME(@SourceDB) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName);
        DECLARE @FullDest NVARCHAR(MAX) = QUOTENAME(@DestDB) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName);

        DECLARE @SQL NVARCHAR(MAX) = '
        IF NOT EXISTS (SELECT 1 FROM ' + QUOTENAME(@DestDB) + '.INFORMATION_SCHEMA.TABLES
                       WHERE TABLE_SCHEMA = ''' + @SchemaName + ''' AND TABLE_NAME = ''' + @TableName + ''')
        BEGIN
            SELECT * INTO ' + @FullDest + ' FROM ' + @FullSource + ' WHERE 1 = 0;
        END';
EXEC sp_executesql @SQL;

        SET @SQL = '
        INSERT INTO ' + @FullDest + '
        SELECT * FROM ' + @FullSource + ' WHERE Created < @CutoffDate;

        DELETE FROM ' + @FullSource + ' WHERE Created < @CutoffDate;';

EXEC sp_executesql @SQL, N'@CutoffDate DATETIME', @CutoffDate;

UPDATE [primeaudit_sandbox].dbo.ArchiveAuditLog
SET EndTime = GETDATE(), Status = 'Success'
WHERE LogID = @LogID;
END TRY
BEGIN CATCH
UPDATE [primeaudit_sandbox].dbo.ArchiveAuditLog
SET EndTime = GETDATE(), Status = 'Error',
    ErrorMessage = ERROR_MESSAGE()
WHERE LogID = @LogID;
END CATCH
END;