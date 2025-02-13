
/****** Object:  StoredProcedure [dbo].[ArchiveAuditTables_Update]    Script Date: 2/11/2025 10:25:25 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ArchiveAuditTables_Update]
ASON
BEGIN
    SET NOCOUNT ON;

    -- Declare configurable variables
    DECLARE @SourceDB NVARCHAR(128) = 'Labkey_testf',
            @DestDB NVARCHAR(128) = 'primeaudit_sandbox',
            @RetentionYears INT = 7,
            @SchemaName NVARCHAR(128) = 'audit';

    -- Calculate cutoff date
    DECLARE @CutoffDate DATETIME = DATEADD(YEAR, -@RetentionYears, GETDATE());

    -- Validate database existence
    IF NOT EXISTS(SELECT 1 FROM sys.databases WHERE name = @SourceDB)
BEGIN
        RAISERROR('Source database "%s" does not exist', 16, 1, @SourceDB);
        RETURN;
END

    IF NOT EXISTS(SELECT 1 FROM sys.databases WHERE name = @DestDB)
BEGIN
        RAISERROR('Destination database "%s" does not exist', 16, 1, @DestDB);
        RETURN;
END

    -- Validate schema existence in source
    DECLARE @SourceSchemaCheck NVARCHAR(MAX) = N'
    IF NOT EXISTS (SELECT 1 FROM ' + QUOTENAME(@SourceDB) + N'.sys.schemas WHERE name = @SchemaName)
    BEGIN
        RAISERROR(''Source schema "%s" does not exist'', 16, 1);
    END';

BEGIN TRY
EXEC sp_executesql @SourceSchemaCheck,
            N'@SchemaName NVARCHAR(128)',
            @SchemaName = @SchemaName;
END TRY
BEGIN CATCH
        DECLARE @SourceSchemaError NVARCHAR(4000) =
            ERROR_MESSAGE() + ' in database ' + @SourceDB;
        RAISERROR(@SourceSchemaError, 16, 1);
        RETURN;
END CATCH

    -- Create schema in destination if needed
    DECLARE @QuotedSchemaName NVARCHAR(128) = QUOTENAME(@SchemaName);
    DECLARE @CreateDestSchemaSQL NVARCHAR(MAX) = N'
    USE ' + QUOTENAME(@DestDB) + N';
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = @SchemaName)
    BEGIN
        EXEC(''CREATE SCHEMA ' + @QuotedSchemaName + N''');
    END';

BEGIN TRY
EXEC sp_executesql @CreateDestSchemaSQL, N'@SchemaName NVARCHAR(128)', @SchemaName;
END TRY
BEGIN CATCH
        DECLARE @DestSchemaError NVARCHAR(4000) =
            'Error creating destination schema: ' + ERROR_MESSAGE();
        RAISERROR(@DestSchemaError, 16, 1);
        RETURN;
END CATCH

    -- Complete table list from original request
	--Modified to provide a lookup of Audit tables in Information_schema.tables
    DECLARE @TableList TABLE (TableName NVARCHAR(128));
INSERT INTO @TableList SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'audit';

-- Cursor to process tables
DECLARE @CurrentTable NVARCHAR(128);
    DECLARE TableCursor CURSOR LOCAL FAST_FORWARD FOR
SELECT TableName FROM @TableList;

OPEN TableCursor;
FETCH NEXT FROM TableCursor INTO @CurrentTable;

WHILE @@FETCH_STATUS = 0
BEGIN
        DECLARE @LogID INT;

        -- Log the start of the operation
INSERT INTO dbo.ArchiveAuditLog (TableName, Operation, StartTime, Status, RetentionYears)
VALUES (@CurrentTable, 'Archive', GETDATE(), 'Started', @RetentionYears);

SET @LogID = SCOPE_IDENTITY(); -- Get the LogID for the current operation

BEGIN TRY
            DECLARE @FullSourceTable NVARCHAR(512) = QUOTENAME(@SourceDB) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@CurrentTable),
                    @FullDestTable NVARCHAR(512) = QUOTENAME(@DestDB) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@CurrentTable),
                    @CheckTableSQL NVARCHAR(MAX),
                    @CreateTableSQL NVARCHAR(MAX),
                    @ArchiveSQL NVARCHAR(MAX),
                    @TableExists BIT = 0;

            -- Check if destination table exists
            SET @CheckTableSQL = N'
            IF NOT EXISTS (SELECT 1
                          FROM ' + QUOTENAME(@DestDB) + N'.INFORMATION_SCHEMA.TABLES
                          WHERE TABLE_SCHEMA = @SchemaName
                            AND TABLE_NAME = @CurrentTable)
            BEGIN
                PRINT ''Skipping table ' + @CurrentTable + N' as it does not exist in the destination database.'';
                RETURN;
            END';

EXEC sp_executesql @CheckTableSQL,
                N'@SchemaName NVARCHAR(128), @CurrentTable NVARCHAR(128)',
                @SchemaName = @SchemaName,
                @CurrentTable = @CurrentTable;

            -- Get the column list (excluding the IDENTITY column)
            DECLARE @ColumnList NVARCHAR(MAX);
SELECT @ColumnList = STRING_AGG(QUOTENAME(COLUMN_NAME), ', ')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @SchemaName
  AND TABLE_NAME = @CurrentTable
  AND COLUMNPROPERTY(OBJECT_ID(QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@CurrentTable)), COLUMN_NAME, 'IsIdentity') = 0;

-- Archive data with transaction
BEGIN TRANSACTION;

            SET @ArchiveSQL = N'
            INSERT INTO ' + @FullDestTable + N' (' + @ColumnList + N')
            SELECT ' + @ColumnList + N'
            FROM ' + @FullSourceTable + N'
            WHERE Created < @CutoffDate;

            -- Capture the number of records inserted
            DECLARE @RecordsInserted INT = @@ROWCOUNT;

            DELETE FROM ' + @FullSourceTable + N'
            WHERE Created < @CutoffDate;

            -- Capture the number of records deleted
            DECLARE @RecordsDeleted INT = @@ROWCOUNT;

            -- Log the total records processed
            UPDATE dbo.ArchiveAuditLog
            SET RecordsProcessed = @RecordsInserted,
                EndTime = GETDATE(),
                Status = ''Success''
            WHERE LogID = @LogID;';

EXEC sp_executesql @ArchiveSQL,
                N'@CutoffDate DATETIME, @LogID INT',
                @CutoffDate = @CutoffDate,
                @LogID = @LogID;

COMMIT TRANSACTION;
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

            -- Log the error
            DECLARE @ErrorMessage NVARCHAR(4000) =
                'Error archiving ' + @CurrentTable + N': ' + ERROR_MESSAGE();

UPDATE dbo.ArchiveAuditLog
SET EndTime = GETDATE(),
    Status = 'Error',
    ErrorMessage = @ErrorMessage
WHERE LogID = @LogID;

PRINT @ErrorMessage; -- Log the error to the console as well
END CATCH

FETCH NEXT FROM TableCursor INTO @CurrentTable;
END

CLOSE TableCursor;
DEALLOCATE TableCursor;
END;
GO


ocessed] [int] NULL)