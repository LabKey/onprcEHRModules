
/****** Object:  StoredProcedure [dbo].[ArchiveAuditTables_DeepSeek1]    Script Date: 5/15/2025 11:50:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ArchiveAuditTables_DeepSeek1]
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare configurable variables
    DECLARE @SourceDB NVARCHAR(128) = 'Labkey_TestF',
            @DestDB NVARCHAR(128) = 'primeaudit_sandbox',
            @RetentionYears INT = 3,
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

    -- Create ArchiveLog table if it doesn't exist
    DECLARE @CreateLogTableSQL NVARCHAR(MAX) = N'
    USE ' + QUOTENAME(@DestDB) + N';
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES
                   WHERE TABLE_SCHEMA = ''dbo'' AND TABLE_NAME = ''ArchiveAuditLog'')
    BEGIN
        CREATE TABLE dbo.ArchiveAuditLog (
            LogID INT IDENTITY(1,1) ,
            TableName NVARCHAR(128) NOT NULL,
            Operation NVARCHAR(50) NOT NULL,
            StartTime DATETIME NOT NULL,
            EndTime DATETIME NULL,
            Status NVARCHAR(50) NULL,
            RecordsProcessed INT NULL,
            ErrorMessage NVARCHAR(MAX) NULL,
            RetentionYears INT NULL
        );
    END';

EXEC sp_executesql @CreateLogTableSQL;

    -- Validate schema existence in source
    IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = @SourceDB)
BEGIN
        RAISERROR('Source database does not exist', 16, 1);
        RETURN;
END

    DECLARE @SourceSchemaCheck NVARCHAR(MAX) = N'
    IF NOT EXISTS (SELECT 1 FROM ' + QUOTENAME(@SourceDB) + N'.sys.schemas WHERE name = ''' + @SchemaName + ''')
    BEGIN
        RAISERROR(''Source schema "%s" does not exist'', 16, 1, ''' + @SchemaName + ''');
    END';

EXEC sp_executesql @SourceSchemaCheck;

    -- Create schema in destination if needed
    DECLARE @CreateDestSchemaSQL NVARCHAR(MAX) = N'
    USE ' + QUOTENAME(@DestDB) + N';
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = ''' + @SchemaName + ''')
    BEGIN
        EXEC(''CREATE SCHEMA ' + QUOTENAME(@SchemaName) + N''');
    END';

EXEC sp_executesql @CreateDestSchemaSQL;

    -- Create temporary table to hold list of tables
CREATE TABLE #TableList (TableName NVARCHAR(128));

-- Get list of audit tables from source database
DECLARE @GetTablesSQL NVARCHAR(MAX) = N'
    INSERT INTO #TableList
    SELECT TABLE_NAME
    FROM ' + QUOTENAME(@SourceDB) + N'.INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = ''' + @SchemaName + '''';

EXEC sp_executesql @GetTablesSQL;

    -- Cursor to process tables
    DECLARE @CurrentTable NVARCHAR(128);
    DECLARE TableCursor CURSOR LOCAL FAST_FORWARD FOR
SELECT TableName FROM #TableList;

OPEN TableCursor;
FETCH NEXT FROM TableCursor INTO @CurrentTable;

WHILE @@FETCH_STATUS = 0
BEGIN
        DECLARE @LogID INT;

        -- Log the start of the operation
        DECLARE @InsertLogSQL NVARCHAR(MAX) = N'
        USE ' + QUOTENAME(@DestDB) + N';
        INSERT INTO dbo.ArchiveAuditLog
            (TableName, Operation, StartTime, Status, RetentionYears)
        VALUES (''' + @CurrentTable + ''', ''Archive'', GETDATE(), ''Started'', ' + CAST(@RetentionYears AS NVARCHAR(10)) + ');
        SELECT @LogIDOUT = SCOPE_IDENTITY();';

EXEC sp_executesql @InsertLogSQL, N'@LogIDOUT INT OUTPUT', @LogIDOUT = @LogID OUTPUT;

BEGIN TRY
            DECLARE @FullSourceTable NVARCHAR(512) = QUOTENAME(@SourceDB) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@CurrentTable),
                    @FullDestTable NVARCHAR(512) = QUOTENAME(@DestDB) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@CurrentTable),
                    @ColumnList NVARCHAR(MAX) = N'';

            -- Check if destination table exists and create if needed
            DECLARE @CheckTableSQL NVARCHAR(MAX) = N'
            USE ' + QUOTENAME(@DestDB) + N';
            IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES
                          WHERE TABLE_SCHEMA = ''' + @SchemaName + '''
                            AND TABLE_NAME = ''' + @CurrentTable + ''')
            BEGIN
                SELECT * INTO ' + @FullDestTable + N'
                FROM ' + @FullSourceTable + N'
                WHERE 1 = 0;
            END';

EXEC sp_executesql @CheckTableSQL;

            -- Get the column list (excluding the IDENTITY column) from source table
CREATE TABLE #Columns (ColumnName NVARCHAR(128), IsIdentity BIT);

DECLARE @GetColumnsSQL NVARCHAR(MAX) = N'
            INSERT INTO #Columns
            SELECT c.name AS ColumnName,
                   COLUMNPROPERTY(OBJECT_ID(''' + QUOTENAME(@SourceDB) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@CurrentTable) + N'''), c.name, ''IsIdentity'') AS IsIdentity
            FROM ' + QUOTENAME(@SourceDB) + N'.sys.columns c
            JOIN ' + QUOTENAME(@SourceDB) + N'.sys.tables t ON c.object_id = t.object_id
            JOIN ' + QUOTENAME(@SourceDB) + N'.sys.schemas s ON t.schema_id = s.schema_id
            WHERE s.name = ''' + @SchemaName + '''
              AND t.name = ''' + @CurrentTable + '''';

EXEC sp_executesql @GetColumnsSQL;

            -- Build column list string
SELECT @ColumnList = @ColumnList + QUOTENAME(ColumnName) + ', '
FROM #Columns
WHERE IsIdentity = 0;

-- Remove trailing comma
IF LEN(@ColumnList) > 0
                SET @ColumnList = LEFT(@ColumnList, LEN(@ColumnList) - 1);

DROP TABLE #Columns;

-- Archive data with transaction
BEGIN TRANSACTION;

            DECLARE @ArchiveSQL NVARCHAR(MAX) = N'
            USE ' + QUOTENAME(@DestDB) + N';
            INSERT INTO ' + @FullDestTable + N' (' + @ColumnList + N')
            SELECT ' + @ColumnList + N'
            FROM ' + @FullSourceTable + N'
            WHERE Created < @CutoffDate;

            DECLARE @RecordsInserted INT = @@ROWCOUNT;

            DELETE FROM ' + @FullSourceTable + N'
            WHERE Created < @CutoffDate;

            DECLARE @RecordsDeleted INT = @@ROWCOUNT;

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

            DECLARE @UpdateLogSQL NVARCHAR(MAX) = N'
            USE ' + QUOTENAME(@DestDB) + N';
            UPDATE dbo.ArchiveAuditLog
            SET EndTime = GETDATE(),
                Status = ''Error'',
                ErrorMessage = @ErrorMessage
            WHERE LogID = ' + CAST(@LogID AS NVARCHAR(10));

EXEC sp_executesql @UpdateLogSQL, N'@ErrorMessage NVARCHAR(4000)', @ErrorMessage = @ErrorMessage;

            PRINT @ErrorMessage;
END CATCH

FETCH NEXT FROM TableCursor INTO @CurrentTable;
END

CLOSE TableCursor;
DEALLOCATE TableCursor;

DROP TABLE #TableList;
END;
