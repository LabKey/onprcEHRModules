DECLARE @ProcSQL NVARCHAR(MAX);

-- Check if the procedure already exists
IF EXISTS (
    SELECT 1
    FROM sys.procedures p
             JOIN sys.schemas s ON p.schema_id = s.schema_id
    WHERE p.name = 'ArchiveAuditTables' AND s.name = 'audit'
)
    BEGIN
        SET @ProcSQL = '
    ALTER PROCEDURE audit.ArchiveAuditTables
        @SourceDB NVARCHAR(128) = NULL,
        @DestDB NVARCHAR(128) = ''primeaudit_sandbox'',
        @RetentionYears INT = 1,
        @SchemaName NVARCHAR(128) = ''audit''
    AS
    BEGIN
        SET NOCOUNT ON;

        -- Set default source DB
        IF @SourceDB IS NULL
            SET @SourceDB = DB_NAME();

        DECLARE @CutoffDate DATETIME = DATEADD(YEAR, -@RetentionYears, GETDATE());

        -- Validate source and destination databases
        IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = @SourceDB)
        BEGIN
            RAISERROR(''Source database "%s" does not exist'', 16, 1, @SourceDB);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = @DestDB)
        BEGIN
            RAISERROR(''Destination database "%s" does not exist'', 16, 1, @DestDB);
            RETURN;
        END

        -- Create ArchiveAuditLog table if it doesn't exist
        DECLARE @CreateLogTableSQL NVARCHAR(MAX) = ''
        IF NOT EXISTS (
            SELECT 1 FROM '' + QUOTENAME(@DestDB) + ''.INFORMATION_SCHEMA.TABLES
            WHERE TABLE_SCHEMA = '''''' + @SchemaName + '''''' AND TABLE_NAME = ''''ArchiveAuditLog''''
        )
            BEGIN
                EXEC(''''CREATE TABLE '' + QUOTENAME(@DestDB) + ''.'' + QUOTENAME(@SchemaName) + ''.ArchiveAuditLog (
                                                                                                                        LogID INT IDENTITY(1,1),
                    TableName NVARCHAR(128) NOT NULL,
                    Operation NVARCHAR(50) NOT NULL,
                    StartTime DATETIME NOT NULL,
                    EndTime DATETIME NULL,
                    Status NVARCHAR(50) NULL,
                    RecordsProcessed INT NULL,
                    ErrorMessage NVARCHAR(MAX) NULL,
                    RetentionYears INT NULL
                    )'''');
            END'';

        EXEC sp_executesql @CreateLogTableSQL;

        -- Get list of audit tables
        CREATE TABLE #TableList (TableName NVARCHAR(128));

        DECLARE @GetTablesSQL NVARCHAR(MAX) = ''
        INSERT INTO #TableList
        SELECT TABLE_NAME
        FROM '' + QUOTENAME(@SourceDB) + ''.INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = '''''' + @SchemaName + '''''''';

        EXEC sp_executesql @GetTablesSQL;

        -- Cursor to loop through tables
        DECLARE @CurrentTable NVARCHAR(128);
        DECLARE TableCursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT TableName FROM #TableList;

        OPEN TableCursor;
        FETCH NEXT FROM TableCursor INTO @CurrentTable;

        WHILE @@FETCH_STATUS = 0
            BEGIN
                DECLARE @LogID INT;

                -- Insert log entry
                DECLARE @InsertLogSQL NVARCHAR(MAX) = ''
                INSERT INTO '' + QUOTENAME(@DestDB) + ''.'' + QUOTENAME(@SchemaName) + ''.ArchiveAuditLog
                (TableName, Operation, StartTime, Status, RetentionYears)
                VALUES (@TableName, ''''Archive'''', GETDATE(), ''''Started'''', @RetentionYears);
                SELECT @LogIDOUT = SCOPE_IDENTITY();'';

                EXEC sp_executesql @InsertLogSQL,
                     N''@TableName NVARCHAR(128), @RetentionYears INT, @LogIDOUT INT OUTPUT'',
                 @TableName = @CurrentTable, @RetentionYears = @RetentionYears, @LogIDOUT = @LogID OUTPUT;

                BEGIN TRY
                    DECLARE @FullSourceTable NVARCHAR(512) = QUOTENAME(@SourceDB) + ''.'' + QUOTENAME(@SchemaName) + ''.'' + QUOTENAME(@CurrentTable),
                        @FullDestTable NVARCHAR(512) = QUOTENAME(@DestDB) + ''.'' + QUOTENAME(@SchemaName) + ''.'' + QUOTENAME(@CurrentTable),
                        @ColumnList NVARCHAR(MAX) = '''';

                    -- Create destination table if it doesn't exist
                    DECLARE @CheckTableSQL NVARCHAR(MAX) = ''
                    IF NOT EXISTS (
                        SELECT 1 FROM '' + QUOTENAME(@DestDB) + ''.INFORMATION_SCHEMA.TABLES
                        WHERE TABLE_SCHEMA = '''''' + @SchemaName + '''''' AND TABLE_NAME = '''''' + @CurrentTable + ''''''
                    )
                        BEGIN
                            SELECT * INTO '' + @FullDestTable + '' FROM '' + @FullSourceTable + '' WHERE 1 = 0;
                        END'';

                    EXEC sp_executesql @CheckTableSQL;

                    -- Get non-identity columns
                    CREATE TABLE #Columns (ColumnName NVARCHAR(128), IsIdentity BIT);

                    DECLARE @GetColumnsSQL NVARCHAR(MAX) = ''
                    INSERT INTO #Columns
                    SELECT c.name,
                           COLUMNPROPERTY(c.object_id, c.name, ''''IsIdentity'''')
                    FROM '' + QUOTENAME(@SourceDB) + ''.sys.columns c
                JOIN '' + QUOTENAME(@SourceDB) + ''.sys.tables t ON c.object_id = t.object_id
                        JOIN '' + QUOTENAME(@SourceDB) + ''.sys.schemas s ON t.schema_id = s.schema_id
                    WHERE s.name = '''''' + @SchemaName + '''''' AND t.name = '''''' + @CurrentTable + '''''''';

                    EXEC sp_executesql @GetColumnsSQL;

                    SELECT @ColumnList = STRING_AGG(QUOTENAME(ColumnName), '', '')
                    FROM #Columns
                    WHERE IsIdentity = 0;

                    DROP TABLE #Columns;

                    -- Archive data
                    BEGIN TRANSACTION;

                    DECLARE @ArchiveSQL NVARCHAR(MAX) = ''
                    INSERT INTO '' + @FullDestTable + '' ('' + @ColumnList + '')
                    SELECT '' + @ColumnList + ''
                    FROM '' + @FullSourceTable + ''
                    WHERE Created < @CutoffDate;

                    DELETE FROM '' + @FullSourceTable + ''
                    WHERE Created < @CutoffDate;'';

                    EXEC sp_executesql @ArchiveSQL,
                         N''@CutoffDate DATETIME'',
                     @CutoffDate = @CutoffDate;

                    DECLARE @RecordsProcessed INT = @@ROWCOUNT;

                    -- Update log
                    DECLARE @UpdateLogSQL NVARCHAR(MAX) = ''
                    UPDATE '' + QUOTENAME(@DestDB) + ''.'' + QUOTENAME(@SchemaName) + ''.ArchiveAuditLog
                    SET RecordsProcessed = @RecordsProcessed,
                    EndTime = GETDATE(),
                    Status = ''''Success''''
                WHERE LogID = @LogID;'';

                    EXEC sp_executesql @UpdateLogSQL,
                         N''@RecordsProcessed INT, @LogID INT'',
                     @RecordsProcessed = @RecordsProcessed,
                     @LogID = @LogID;

                    COMMIT TRANSACTION;
                END TRY
                BEGIN CATCH
                    IF @@TRANCOUNT > 0
                        ROLLBACK TRANSACTION;

                    DECLARE @ErrorMessage NVARCHAR(4000) =
                        ''Error archiving '' + @CurrentTable + '': '' + ERROR_MESSAGE();

                    DECLARE @UpdateLogSQL_gj NVARCHAR(MAX) = ''
                    UPDATE '' + QUOTENAME(@DestDB) + ''.'' + QUOTENAME(@SchemaName) + ''.ArchiveAuditLog
                    SET EndTime = GETDATE(),
                    Status = ''''Error'''',
                    ErrorMessage = @ErrorMessage
                WHERE LogID = @LogID;'';

                    EXEC sp_executesql @UpdateLogSQL_gj,
                         N''@ErrorMessage NVARCHAR(4000), @LogID INT'',
                     @ErrorMessage = @ErrorMessage, @LogID = @LogID;

                    PRINT @ErrorMessage;
                END CATCH

                FETCH NEXT FROM TableCursor INTO @CurrentTable;
            END

        CLOSE TableCursor;
        DEALLOCATE TableCursor;

        DROP TABLE #TableList;
    END';
END
ELSE
BEGIN
    SET @ProcSQL = REPLACE(@ProcSQL, 'ALTER PROCEDURE', 'CREATE PROCEDURE');
END

-- Execute the dynamic SQL
EXEC sp_executesql @ProcSQL;
