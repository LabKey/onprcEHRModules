← →
edited onprc_ehr/resources/schemas/dbscripts/sqlserver/onprc_ehr-24.011-24.012.sql
Appearance

 Ignore whitespaces Open in IDE
User avatar⁠ Gerald D Jones (OHSU): Update to ALTER TRABLE TO include schema name, this passed ion Dev after clower inspection
                                               CopyCopy

/****** Object:  StoredProcedure [audit].[ArchiveAuditTables]    Script Date: 7/16/2025 7:59:34 AM ******/
                                    SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [audit].[ArchiveAuditTables]
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare variables
    DECLARE @SourceDB NVARCHAR(128) = DB_NAME(),
            @DestDB NVARCHAR(128) = 'primeaudit_sandbox',
            @RetentionYears INT = 7,
            @SchemaName NVARCHAR(128) = 'audit';

    DECLARE @CutoffDate DATETIME = DATEADD(YEAR, -@RetentionYears, GETDATE());

    -- Validate if source database exists
    IF NOT EXISTS(SELECT 1 FROM sys.databases WHERE name = @SourceDB)
BEGIN
        RAISERROR('Source database "%s" does not exist.', 16, 1, @SourceDB);
        RETURN;
END

    -- Validate if destination database exists
    IF NOT EXISTS(SELECT 1 FROM sys.databases WHERE name = @DestDB)
BEGIN
        RAISERROR('Destination database "%s" does not exist.', 16, 1, @DestDB);
        RETURN;
END

    -- Create ArchiveAuditLog table if not exists
    DECLARE @CreateLogTableSQL NVARCHAR(MAX) = '
    IF NOT EXISTS (SELECT 1 FROM ' + QUOTENAME(@DestDB) + '.INFORMATION_SCHEMA.TABLES
                   WHERE TABLE_SCHEMA = ''dbo'' AND TABLE_NAME = ''ArchiveAuditLog'')
    BEGIN
        EXEC(''USE ' + QUOTENAME(@DestDB) + ';
        CREATE TABLE dbo.ArchiveAuditLog (
            LogID INT IDENTITY(1,1) PRIMARY KEY,
            TableName NVARCHAR(128) NOT NULL,
            Operation NVARCHAR(50) NOT NULL,
            StartTime DATETIME NOT NULL,
            EndTime DATETIME NULL,
            Status NVARCHAR(50) NULL,
            RecordsProcessed INT NULL,
            ErrorMessage NVARCHAR(MAX) NULL,
            RetentionYears INT NULL
        )'');
    END';
EXEC sp_executesql @CreateLogTableSQL;

    -- Validate if source schema exists
    DECLARE @SourceSchemaCheck NVARCHAR(MAX) = '
    IF NOT EXISTS (SELECT 1 FROM ' + QUOTENAME(@SourceDB) + '.sys.schemas WHERE name = ''' + @SchemaName + ''')
    BEGIN
        RAISERROR(''Source schema "%s" does not exist'', 16, 1, ''' + @SchemaName + ''');
    END';

EXEC sp_executesql @SourceSchemaCheck;

    DECLARE @CreateDestSchemaSQL NVARCHAR(MAX) = '
    IF NOT EXISTS (SELECT 1 FROM ' + QUOTENAME(@DestDB) + '.sys.schemas WHERE name = ''' + @SchemaName + ''')
    BEGIN
        EXEC(''USE ' + QUOTENAME(@DestDB) + '; CREATE SCHEMA ' + QUOTENAME(@SchemaName) + ''');
    END';

EXEC sp_executesql @CreateDestSchemaSQL;

CREATE TABLE #TableList (TableName NVARCHAR(128));

DECLARE @GetTablesSQL NVARCHAR(MAX) = '
    INSERT INTO #TableList
    SELECT TABLE_NAME
    FROM ' + QUOTENAME(@SourceDB) + '.INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = ''' + @SchemaName + '''';

EXEC sp_executesql @GetTablesSQL;

    DECLARE @CurrentTable NVARCHAR(128);
    DECLARE TableCursor CURSOR LOCAL FAST_FORWARD FOR
SELECT TableName FROM #TableList;

OPEN TableCursor;
FETCH NEXT FROM TableCursor INTO @CurrentTable;

WHILE @@FETCH_STATUS = 0
BEGIN
        DECLARE @LogID INT;

        DECLARE @InsertLogSQL NVARCHAR(MAX) = '
        USE ' + QUOTENAME(@DestDB) + ';
        INSERT INTO dbo.ArchiveAuditLog
            (TableName, Operation, StartTime, Status, RetentionYears)
        VALUES (''' + @CurrentTable + ''', ''Archive'', GETDATE(), ''Started'', ' + CAST(@RetentionYears AS NVARCHAR(10)) + ');
        SELECT @LogIDOUT = SCOPE_IDENTITY();';

EXEC sp_executesql @InsertLogSQL, N'@LogIDOUT INT OUTPUT', @LogIDOUT = @LogID OUTPUT;

BEGIN TRY
            DECLARE @FullSourceTable NVARCHAR(512) = QUOTENAME(@SourceDB) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@CurrentTable),
                    @FullDestTable NVARCHAR(512) = QUOTENAME(@DestDB) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@CurrentTable),
                    @ColumnList NVARCHAR(MAX) = '';

            DECLARE @CheckTableSQL NVARCHAR(MAX) = '
            IF NOT EXISTS (SELECT 1 FROM ' + QUOTENAME(@DestDB) + '.INFORMATION_SCHEMA.TABLES
                          WHERE TABLE_SCHEMA = ''' + @SchemaName + '''
                            AND TABLE_NAME = ''' + @CurrentTable + ''')
            BEGIN
                SELECT * INTO ' + @FullDestTable + '
                FROM ' + @FullSourceTable + '
                WHERE 1 = 0;
            END';

EXEC sp_executesql @CheckTableSQL;

CREATE TABLE #Columns (ColumnName NVARCHAR(128), IsIdentity BIT);

DECLARE @GetColumnsSQL NVARCHAR(MAX) = '
            INSERT INTO #Columns
            SELECT c.name AS ColumnName,
                   COLUMNPROPERTY(OBJECT_ID(''' + @FullSourceTable + '''), c.name, ''IsIdentity'') AS IsIdentity
            FROM ' + QUOTENAME(@SourceDB) + '.sys.columns c
            JOIN ' + QUOTENAME(@SourceDB) + '.sys.tables t ON c.object_id = t.object_id
            JOIN ' + QUOTENAME(@SourceDB) + '.sys.schemas s ON t.schema_id = s.schema_id
            WHERE s.name = ''' + @SchemaName + '''
              AND t.name = ''' + @CurrentTable + '''';

EXEC sp_executesql @GetColumnsSQL;

SELECT @ColumnList = STRING_AGG(QUOTENAME(ColumnName), ', ')
FROM #Columns
WHERE IsIdentity = 0;

DROP TABLE #Columns;

BEGIN TRANSACTION;

            DECLARE @ArchiveSQL NVARCHAR(MAX) = '
            INSERT INTO ' + @FullDestTable + ' (' + @ColumnList + ')
            SELECT ' + @ColumnList + '
            FROM ' + @FullSourceTable + '
            WHERE Created < @CutoffDate;

            DECLARE @RecordsInserted INT = @@ROWCOUNT;

            DELETE FROM ' + @FullSourceTable + '
            WHERE Created < @CutoffDate;

            DECLARE @RecordsDeleted INT = @@ROWCOUNT;

            UPDATE ' + QUOTENAME(@DestDB) + '.dbo.ArchiveAuditLog
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

            DECLARE @ErrorMessage NVARCHAR(4000) =
                'Error archiving ' + @CurrentTable + ': ' + ERROR_MESSAGE();

            DECLARE @UpdateLogSQL NVARCHAR(MAX) = '
            UPDATE ' + QUOTENAME(@DestDB) + '.dbo.ArchiveAuditLog
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
END




/****** Object:  StoredProcedure [audit].[ArchiveAuditTables]    Script Date: 7/16/2025 7:59:34 AM ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

ALTER PROCEDURE [audit].[ArchiveAuditTables]
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare variables
    DECLARE @SourceDB NVARCHAR(128) = DB_NAME(),
            @DestDB NVARCHAR(128) = 'primeaudit_sandbox',
            @RetentionYears INT = 1,
            @SchemaName NVARCHAR(128) = 'audit';

    DECLARE @CutoffDate DATETIME = DATEADD(YEAR, -@RetentionYears, GETDATE());

    -- Validate if source database exists
    IF NOT EXISTS(SELECT 1 FROM sys.databases WHERE name = @SourceDB)
BEGIN
        RAISERROR('Source database "%s" does not exist.', 16, 1, @SourceDB);
        RETURN;
END

    -- Validate if destination database exists
    IF NOT EXISTS(SELECT 1 FROM sys.databases WHERE name = @DestDB)
BEGIN
        RAISERROR('Destination database "%s" does not exist.', 16, 1, @DestDB);
        RETURN;
END

    -- Create ArchiveAuditLog table if not exists
    DECLARE @CreateLogTableSQL NVARCHAR(MAX) = '
    IF NOT EXISTS (SELECT 1 FROM ' + QUOTENAME(@DestDB) + '.INFORMATION_SCHEMA.TABLES
                   WHERE TABLE_SCHEMA = ''dbo'' AND TABLE_NAME = ''ArchiveAuditLog'')
    BEGIN
        EXEC(''USE ' + QUOTENAME(@DestDB) + ';
        CREATE TABLE dbo.ArchiveAuditLog (
            LogID INT IDENTITY(1,1) PRIMARY KEY,
            TableName NVARCHAR(128) NOT NULL,
            Operation NVARCHAR(50) NOT NULL,
            StartTime DATETIME NOT NULL,
            EndTime DATETIME NULL,
            Status NVARCHAR(50) NULL,
            RecordsProcessed INT NULL,
            ErrorMessage NVARCHAR(MAX) NULL,
            RetentionYears INT NULL
        )'');
    END';
EXEC sp_executesql @CreateLogTableSQL;

    -- Validate if source schema exists
    DECLARE @SourceSchemaCheck NVARCHAR(MAX) = '
    IF NOT EXISTS (SELECT 1 FROM ' + QUOTENAME(@SourceDB) + '.sys.schemas WHERE name = ''' + @SchemaName + ''')
    BEGIN
        RAISERROR(''Source schema "%s" does not exist'', 16, 1, ''' + @SchemaName + ''');
    END';

EXEC sp_executesql @SourceSchemaCheck;

    DECLARE @CreateDestSchemaSQL NVARCHAR(MAX) = '
    IF NOT EXISTS (SELECT 1 FROM ' + QUOTENAME(@DestDB) + '.sys.schemas WHERE name = ''' + @SchemaName + ''')
    BEGIN
        EXEC(''USE ' + QUOTENAME(@DestDB) + '; CREATE SCHEMA ' + QUOTENAME(@SchemaName) + ''');
    END';

EXEC sp_executesql @CreateDestSchemaSQL;

CREATE TABLE #TableList (TableName NVARCHAR(128));

DECLARE @GetTablesSQL NVARCHAR(MAX) = '
    INSERT INTO #TableList
    SELECT TABLE_NAME
    FROM ' + QUOTENAME(@SourceDB) + '.INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = ''' + @SchemaName + '''';

EXEC sp_executesql @GetTablesSQL;

    DECLARE @CurrentTable NVARCHAR(128);
    DECLARE TableCursor CURSOR LOCAL FAST_FORWARD FOR
SELECT TableName FROM #TableList;

OPEN TableCursor;
FETCH NEXT FROM TableCursor INTO @CurrentTable;

WHILE @@FETCH_STATUS = 0
BEGIN
        DECLARE @LogID INT;

        DECLARE @InsertLogSQL NVARCHAR(MAX) = '
        USE ' + QUOTENAME(@DestDB) + ';
        INSERT INTO dbo.ArchiveAuditLog
            (TableName, Operation, StartTime, Status, RetentionYears)
        VALUES (''' + @CurrentTable + ''', ''Archive'', GETDATE(), ''Started'', ' + CAST(@RetentionYears AS NVARCHAR(10)) + ');
        SELECT @LogIDOUT = SCOPE_IDENTITY();';

EXEC sp_executesql @InsertLogSQL, N'@LogIDOUT INT OUTPUT', @LogIDOUT = @LogID OUTPUT;

BEGIN TRY
            DECLARE @FullSourceTable NVARCHAR(512) = QUOTENAME(@SourceDB) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@CurrentTable),
                    @FullDestTable NVARCHAR(512) = QUOTENAME(@DestDB) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@CurrentTable),
                    @ColumnList NVARCHAR(MAX) = '';

            DECLARE @CheckTableSQL NVARCHAR(MAX) = '
            IF NOT EXISTS (SELECT 1 FROM ' + QUOTENAME(@DestDB) + '.INFORMATION_SCHEMA.TABLES
                          WHERE TABLE_SCHEMA = ''' + @SchemaName + '''
                            AND TABLE_NAME = ''' + @CurrentTable + ''')
            BEGIN
                SELECT * INTO ' + @FullDestTable + '
                FROM ' + @FullSourceTable + '
                WHERE 1 = 0;
            END';

EXEC sp_executesql @CheckTableSQL;

CREATE TABLE #Columns (ColumnName NVARCHAR(128), IsIdentity BIT);

DECLARE @GetColumnsSQL NVARCHAR(MAX) = '
            INSERT INTO #Columns
            SELECT c.name AS ColumnName,
                   COLUMNPROPERTY(OBJECT_ID(''' + @FullSourceTable + '''), c.name, ''IsIdentity'') AS IsIdentity
            FROM ' + QUOTENAME(@SourceDB) + '.sys.columns c
            JOIN ' + QUOTENAME(@SourceDB) + '.sys.tables t ON c.object_id = t.object_id
            JOIN ' + QUOTENAME(@SourceDB) + '.sys.schemas s ON t.schema_id = s.schema_id
            WHERE s.name = ''' + @SchemaName + '''
              AND t.name = ''' + @CurrentTable + '''';

EXEC sp_executesql @GetColumnsSQL;

SELECT @ColumnList = STRING_AGG(QUOTENAME(ColumnName), ', ')
FROM #Columns
WHERE IsIdentity = 0;

DROP TABLE #Columns;

BEGIN TRANSACTION;

            DECLARE @ArchiveSQL NVARCHAR(MAX) = '
            INSERT INTO ' + @FullDestTable + ' (' + @ColumnList + ')
            SELECT ' + @ColumnList + '
            FROM ' + @FullSourceTable + '
            WHERE Created < @CutoffDate;

            DECLARE @RecordsInserted INT = @@ROWCOUNT;

            DELETE FROM ' + @FullSourceTable + '
            WHERE Created < @CutoffDate;

            DECLARE @RecordsDeleted INT = @@ROWCOUNT;

            UPDATE ' + QUOTENAME(@DestDB) + '.dbo.ArchiveAuditLog
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

            DECLARE @ErrorMessage NVARCHAR(4000) =
                'Error archiving ' + @CurrentTable + ': ' + ERROR_MESSAGE();

            DECLARE @UpdateLogSQL NVARCHAR(MAX) = '
            UPDATE ' + QUOTENAME(@DestDB) + '.dbo.ArchiveAuditLog
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
END
/*Validated with AI IN Code*/

