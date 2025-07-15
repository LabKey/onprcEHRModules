IF NOT EXISTS (
    SELECT 1
    FROM sys.procedures p
    JOIN sys.schemas s ON p.schema_id = s.schema_id
    WHERE p.name = 'ArchiveAuditTables' AND s.name = 'audit'
)
BEGIN
EXEC('
    CREATE PROCEDURE audit.ArchiveAuditTables
        @SourceDB NVARCHAR(128) = NULL,
        @DestDB NVARCHAR(128) = ''primeaudit_sandbox'',
        @RetentionYears INT = 1,
        @SchemaName NVARCHAR(128) = ''audit''
    AS
    BEGIN
        SET NOCOUNT ON;
        SET XACT_ABORT ON;

        -- Set default source DB
        IF @SourceDB IS NULL
            SET @SourceDB = DB_NAME();

        DECLARE @CutoffDate DATETIME = DATEADD(YEAR, -@RetentionYears, GETDATE());

        -- Validate databases
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

        -- Ensure log table exists
        DECLARE @LogTable NVARCHAR(500) = QUOTENAME(@DestDB) + ''.'' + QUOTENAME(@SchemaName) + ''.ArchiveAuditLog'';
        IF OBJECT_ID(@LogTable, ''U'') IS NULL
        BEGIN
            EXEC(''
                CREATE TABLE '' + @LogTable + '' (
                    LogID INT IDENTITY(1,1) PRIMARY KEY,
                    TableName NVARCHAR(128) NOT NULL,
                    Operation NVARCHAR(50) NOT NULL,
                    StartTime DATETIME NOT NULL,
                    EndTime DATETIME NULL,
                    Status NVARCHAR(50) NULL,
                    RecordsProcessed INT NULL,
                    ErrorMessage NVARCHAR(MAX) NULL,
                    RetentionYears INT NULL
                )
            '');
        END

        -- Get tables to process
        CREATE TABLE #Tables (TableName NVARCHAR(128) PRIMARY KEY);
        DECLARE @GetTablesSQL NVARCHAR(MAX) = ''
            INSERT INTO #Tables
            SELECT t.name
            FROM '' + QUOTENAME(@SourceDB) + ''.sys.tables t
            JOIN '' + QUOTENAME(@SourceDB) + ''.sys.schemas s ON t.schema_id = s.schema_id
            WHERE s.name = '''''' + @SchemaName + ''''''
        '';
        EXEC sp_executesql @GetTablesSQL;

        DECLARE @TableName NVARCHAR(128), @LogID INT, @RecordsProcessed INT;
        DECLARE @SrcTable NVARCHAR(500), @DstTable NVARCHAR(500);
        DECLARE @SQL NVARCHAR(MAX), @ErrorMsg NVARCHAR(MAX);

        WHILE EXISTS (SELECT 1 FROM #Tables)
        BEGIN
            SELECT TOP 1 @TableName = TableName FROM #Tables;

            -- Initialize variables
            SET @SrcTable = QUOTENAME(@SourceDB) + ''.'' + QUOTENAME(@SchemaName) + ''.'' + QUOTENAME(@TableName);
            SET @DstTable = QUOTENAME(@DestDB) + ''.'' + QUOTENAME(@SchemaName) + ''.'' + QUOTENAME(@TableName);

            -- Start log entry
            INSERT INTO audit.ArchiveAuditLog (
                TableName, Operation, StartTime, Status, RetentionYears
            ) VALUES (
                @TableName, ''Archive'', GETDATE(), ''Started'', @RetentionYears
            );
            SET @LogID = SCOPE_IDENTITY();

            BEGIN TRY
                -- Create destination table if missing
                IF OBJECT_ID(@DstTable, ''U'') IS NULL
                BEGIN
                    EXEC(''
                        SELECT * INTO '' + @DstTable + ''
                        FROM '' + @SrcTable + ''
                        WHERE 1 = 0
                    '');
                END

                BEGIN TRANSACTION;

                -- Archive data
                SET @SQL = ''
                    INSERT INTO '' + @DstTable + ''
                    SELECT *
                    FROM '' + @SrcTable + ''
                    WHERE Created < @CutoffDate;

                    DELETE FROM '' + @SrcTable + ''
                    WHERE Created < @CutoffDate;
                '';
                EXEC sp_executesql @SQL, N''@CutoffDate DATETIME'', @CutoffDate;
                SET @RecordsProcessed = @@ROWCOUNT;

                -- Update log
                UPDATE audit.ArchiveAuditLog
                SET
                    EndTime = GETDATE(),
                    Status = ''Success'',
                    RecordsProcessed = @RecordsProcessed
                WHERE LogID = @LogID;

                COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

                SET @ErrorMsg = ''Error archiving '' + @TableName + '': '' + ERROR_MESSAGE();

                UPDATE audit.ArchiveAuditLog
                SET
                    EndTime = GETDATE(),
                    Status = ''Error'',
                    ErrorMessage = @ErrorMsg
                WHERE LogID = @LogID;

                RAISERROR(@ErrorMsg, 16, 1);
            END CATCH

            DELETE FROM #Tables WHERE TableName = @TableName;
        END

        DROP TABLE #Tables;
    END');
END
ELSE
BEGIN
EXEC('
    ALTER PROCEDURE audit.ArchiveAuditTables
        @SourceDB NVARCHAR(128) = NULL,
        @DestDB NVARCHAR(128) = ''primeaudit_sandbox'',
        @RetentionYears INT = 1,
        @SchemaName NVARCHAR(128) = ''audit''
    AS
    BEGIN
        SET NOCOUNT ON;
        SET XACT_ABORT ON;

        -- Set default source DB
        IF @SourceDB IS NULL
            SET @SourceDB = DB_NAME();

        DECLARE @CutoffDate DATETIME = DATEADD(YEAR, -@RetentionYears, GETDATE());

        -- Validate databases
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

        -- Ensure log table exists
        DECLARE @LogTable NVARCHAR(500) = QUOTENAME(@DestDB) + ''.'' + QUOTENAME(@SchemaName) + ''.ArchiveAuditLog'';
        IF OBJECT_ID(@LogTable, ''U'') IS NULL
        BEGIN
            EXEC(''
                CREATE TABLE '' + @LogTable + '' (
                    LogID INT IDENTITY(1,1) PRIMARY KEY,
                    TableName NVARCHAR(128) NOT NULL,
                    Operation NVARCHAR(50) NOT NULL,
                    StartTime DATETIME NOT NULL,
                    EndTime DATETIME NULL,
                    Status NVARCHAR(50) NULL,
                    RecordsProcessed INT NULL,
                    ErrorMessage NVARCHAR(MAX) NULL,
                    RetentionYears INT NULL
                )
            '');
        END

        -- Get tables to process
        CREATE TABLE #Tables (TableName NVARCHAR(128) PRIMARY KEY);
        DECLARE @GetTablesSQL NVARCHAR(MAX) = ''
            INSERT INTO #Tables
            SELECT t.name
            FROM '' + QUOTENAME(@SourceDB) + ''.sys.tables t
            JOIN '' + QUOTENAME(@SourceDB) + ''.sys.schemas s ON t.schema_id = s.schema_id
            WHERE s.name = '''''' + @SchemaName + ''''''
        '';
        EXEC sp_executesql @GetTablesSQL;

        DECLARE @TableName NVARCHAR(128), @LogID INT, @RecordsProcessed INT;
        DECLARE @SrcTable NVARCHAR(500), @DstTable NVARCHAR(500);
        DECLARE @SQL NVARCHAR(MAX), @ErrorMsg NVARCHAR(MAX);

        WHILE EXISTS (SELECT 1 FROM #Tables)
        BEGIN
            SELECT TOP 1 @TableName = TableName FROM #Tables;

            -- Initialize variables
            SET @SrcTable = QUOTENAME(@SourceDB) + ''.'' + QUOTENAME(@SchemaName) + ''.'' + QUOTENAME(@TableName);
            SET @DstTable = QUOTENAME(@DestDB) + ''.'' + QUOTENAME(@SchemaName) + ''.'' + QUOTENAME(@TableName);

            -- Start log entry
            INSERT INTO audit.ArchiveAuditLog (
                TableName, Operation, StartTime, Status, RetentionYears
            ) VALUES (
                @TableName, ''Archive'', GETDATE(), ''Started'', @RetentionYears
            );
            SET @LogID = SCOPE_IDENTITY();

            BEGIN TRY
                -- Create destination table if missing
                IF OBJECT_ID(@DstTable, ''U'') IS NULL
                BEGIN
                    EXEC(''
                        SELECT * INTO '' + @DstTable + ''
                        FROM '' + @SrcTable + ''
                        WHERE 1 = 0
                    '');
                END

                BEGIN TRANSACTION;

                -- Archive data
                SET @SQL = ''
                    INSERT INTO '' + @DstTable + ''
                    SELECT *
                    FROM '' + @SrcTable + ''
                    WHERE Created < @CutoffDate;

                    DELETE FROM '' + @SrcTable + ''
                    WHERE Created < @CutoffDate;
                '';
                EXEC sp_executesql @SQL, N''@CutoffDate DATETIME'', @CutoffDate;
                SET @RecordsProcessed = @@ROWCOUNT;

                -- Update log
                UPDATE audit.ArchiveAuditLog
                SET
                    EndTime = GETDATE(),
                    Status = ''Success'',
                    RecordsProcessed = @RecordsProcessed
                WHERE LogID = @LogID;

                COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

                SET @ErrorMsg = ''Error archiving '' + @TableName + '': '' + ERROR_MESSAGE();

                UPDATE audit.ArchiveAuditLog
                SET
                    EndTime = GETDATE(),
                    Status = ''Error'',
                    ErrorMessage = @ErrorMsg
                WHERE LogID = @LogID;

                RAISERROR(@ErrorMsg, 16, 1);
            END CATCH

            DELETE FROM #Tables WHERE TableName = @TableName;
        END

        DROP TABLE #Tables;
    END');
END