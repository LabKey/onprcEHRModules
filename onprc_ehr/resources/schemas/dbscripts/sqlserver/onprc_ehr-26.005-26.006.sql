/* ============================================================================
   usp_PreflightMissingFields
   ----------------------------------------------------------------------------
   Purpose:
     Preflight check: reports columns that exist in the source table but are
     missing from the corresponding target table. Only considers tables that
     already exist in both databases.

   Usage:
     EXEC dbo.usp_PreflightMissingFields
          @SourceDatabase = 'LabKey',
          @SourceSchema   = 'audit',
          @TargetDatabase = 'labkey_audit',
          @TargetSchema   = 'dbo',
          @PersistResults = 1;

   Requires VIEW DEFINITION (or db_datareader) on both databases for the
   executing login.
   ============================================================================ */

CREATE OR ALTER PROCEDURE dbo.usp_PreflightMissingFields
    @SourceDatabase   sysname = N'LabKey_testF',
    @SourceSchema     sysname = N'audit',
    @TargetDatabase   sysname = N'labkey_audit',
    @TargetSchema     sysname = N'audit',
    @PersistResults   bit     = 1,
    @FailOnMissing    bit     = 0   -- 1 = halt pipeline if any missing field is found
    AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RunId   uniqueidentifier = NEWID();
    DECLARE @RunDate datetime2(0)     = SYSUTCDATETIME();
    DECLARE @sql     nvarchar(max);

    ----------------------------------------------------------------------
    -- 1. Snapshot column metadata from both databases
    ----------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#SourceCols') IS NOT NULL DROP TABLE #SourceCols;
IF OBJECT_ID('tempdb..#TargetCols') IS NOT NULL DROP TABLE #TargetCols;

CREATE TABLE #SourceCols
(
    TableName        sysname,
    ColumnName       sysname,
    DataType         sysname,
    CharMaxLength    int NULL,
    NumericPrecision tinyint NULL,
    NumericScale     int NULL,
    IsNullable       bit NULL
);

CREATE TABLE #TargetCols
(
    TableName        sysname,
    ColumnName       sysname,
    DataType         sysname,
    CharMaxLength    int NULL,
    NumericPrecision tinyint NULL,
    NumericScale     int NULL
);

SET @sql = N'
        SELECT c.TABLE_NAME, c.COLUMN_NAME, c.DATA_TYPE,
               c.CHARACTER_MAXIMUM_LENGTH, c.NUMERIC_PRECISION, c.NUMERIC_SCALE,
               CASE WHEN c.IS_NULLABLE = ''YES'' THEN 1 ELSE 0 END
        FROM ' + QUOTENAME(@SourceDatabase) + N'.INFORMATION_SCHEMA.COLUMNS c
        WHERE c.TABLE_SCHEMA = @Schema';

INSERT INTO #SourceCols
    EXEC sp_executesql @sql, N'@Schema sysname', @Schema = @SourceSchema;

SET @sql = N'
        SELECT c.TABLE_NAME, c.COLUMN_NAME, c.DATA_TYPE,
               c.CHARACTER_MAXIMUM_LENGTH, c.NUMERIC_PRECISION, c.NUMERIC_SCALE
        FROM ' + QUOTENAME(@TargetDatabase) + N'.INFORMATION_SCHEMA.COLUMNS c
        WHERE c.TABLE_SCHEMA = @Schema';

INSERT INTO #TargetCols
    EXEC sp_executesql @sql, N'@Schema sysname', @Schema = @TargetSchema;

----------------------------------------------------------------------
-- 2. Find columns in source table that are missing from target table
--    (only for tables that already exist in both)
----------------------------------------------------------------------
IF OBJECT_ID('tempdb..#Findings') IS NOT NULL DROP TABLE #Findings;

CREATE TABLE #Findings
(
    RunId             uniqueidentifier,
    RunDate           datetime2(0),
    CheckType         varchar(20),
    TableName         sysname,
    ColumnName        sysname,
    SourceDetail      nvarchar(200),
    TargetDetail      nvarchar(200),
    Severity          varchar(20),
    Recommendation    nvarchar(400),
    GeneratedStatement nvarchar(1000)
);

-- Build a display type clause and a real T-SQL type clause (used in the ALTER statement)
-- for each missing column. Covers the common cases: char/binary family (length, or MAX
-- when CharMaxLength = -1), decimal/numeric (precision,scale), and everything else as-is.
-- New columns are always added as NULL regardless of the source's nullability, since the
-- target table may already have rows and a NOT NULL add would require a DEFAULT — the
-- source nullability is included as a comment so a human can decide whether to tighten it.
INSERT INTO #Findings
SELECT @RunId, @RunDate, 'NEW_COLUMN', s.TableName, s.ColumnName,
       s.DataType +
       CASE WHEN s.CharMaxLength IS NOT NULL THEN '(' + CASE WHEN s.CharMaxLength = -1 THEN 'MAX' ELSE CAST(s.CharMaxLength AS varchar(10)) END + ')'
            WHEN s.NumericPrecision IS NOT NULL THEN '(' + CAST(s.NumericPrecision AS varchar(10)) +
                                                     CASE WHEN s.NumericScale IS NOT NULL THEN ',' + CAST(s.NumericScale AS varchar(10)) ELSE '' END + ')'
            ELSE '' END,
       'missing',
       'ACTION_REQUIRED',
       'Add column to target table before copying data for this field.',
       'ALTER TABLE ' + QUOTENAME(@TargetSchema) + '.' + QUOTENAME(s.TableName) +
       ' ADD ' + QUOTENAME(s.ColumnName) + ' ' +
       CASE
           WHEN s.DataType IN ('varchar','nvarchar','char','nchar','varbinary','binary')
               THEN s.DataType + '(' + CASE WHEN s.CharMaxLength = -1 THEN 'MAX' ELSE CAST(ISNULL(s.CharMaxLength,1) AS varchar(10)) END + ')'
           WHEN s.DataType IN ('decimal','numeric')
               THEN s.DataType + '(' + CAST(ISNULL(s.NumericPrecision,18) AS varchar(10)) + ',' + CAST(ISNULL(s.NumericScale,0) AS varchar(10)) + ')'
           ELSE s.DataType
           END +
       ' NULL;  -- source column is ' + CASE WHEN s.IsNullable = 1 THEN 'NULLABLE' ELSE 'NOT NULL (review whether a DEFAULT + NOT NULL is needed here)' END
FROM #SourceCols s
WHERE EXISTS (SELECT 1 FROM #TargetCols t2 WHERE t2.TableName = s.TableName)   -- table exists in target
  AND NOT EXISTS (SELECT 1 FROM #TargetCols t WHERE t.TableName = s.TableName AND t.ColumnName = s.ColumnName);

----------------------------------------------------------------------
-- 3. Persist (optional) and return results
----------------------------------------------------------------------
IF @PersistResults = 1
BEGIN
        IF OBJECT_ID('dbo.AuditMissingFieldsLog') IS NULL
BEGIN
CREATE TABLE dbo.AuditMissingFieldsLog
(
    LogId              bigint IDENTITY(1,1) PRIMARY KEY,
    RunId              uniqueidentifier NOT NULL,
    RunDate            datetime2(0) NOT NULL,
    CheckType          varchar(20) NOT NULL,
    TableName          sysname NOT NULL,
    ColumnName         sysname NOT NULL,
    SourceDetail       nvarchar(200) NULL,
    TargetDetail       nvarchar(200) NULL,
    Severity           varchar(20) NOT NULL,
    Recommendation     nvarchar(400) NULL,
    GeneratedStatement nvarchar(1000) NULL,
    ScriptExecuted     bit NOT NULL DEFAULT (0)   -- human flips this to 1 after running the fix
);
END;

INSERT INTO dbo.AuditMissingFieldsLog
(RunId, RunDate, CheckType, TableName, ColumnName, SourceDetail, TargetDetail, Severity, Recommendation, GeneratedStatement)
SELECT RunId, RunDate, CheckType, TableName, ColumnName, SourceDetail, TargetDetail, Severity, Recommendation, GeneratedStatement
FROM #Findings;
END;

SELECT * FROM #Findings ORDER BY TableName, ColumnName;

----------------------------------------------------------------------
-- 3b. Build a single consolidated fix script for a human to review and run
--     against the target database. Returned as its own result set so it
--     can be copied straight into a new query window.
----------------------------------------------------------------------
DECLARE @FixScript nvarchar(max);

SELECT @FixScript =
       N'-- ============================================================' + CHAR(13) + CHAR(10) +
    N'-- Auto-generated fix script - RunId: ' + CAST(@RunId AS varchar(36)) + CHAR(13) + CHAR(10) +
    N'-- Generated: ' + CONVERT(varchar(30), @RunDate, 120) + ' UTC' + CHAR(13) + CHAR(10) +
    N'-- Adds columns found in ' + @SourceDatabase + '.' + @SourceSchema +
    N' but missing from ' + @TargetDatabase + '.' + @TargetSchema + CHAR(13) + CHAR(10) +
    N'-- REVIEW BEFORE RUNNING. Columns are added as NULL; tighten to NOT NULL' + CHAR(13) + CHAR(10) +
    N'-- with a DEFAULT only after confirming existing rows can be backfilled.' + CHAR(13) + CHAR(10) +
    N'-- ============================================================' + CHAR(13) + CHAR(10) +
    N'USE ' + QUOTENAME(@TargetDatabase) + ';' + CHAR(13) + CHAR(10) + N'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
    ISNULL((
    SELECT GeneratedStatement + CHAR(13) + CHAR(10)
    FROM #Findings
    ORDER BY TableName, ColumnName
    FOR XML PATH(''), TYPE
    ).value('.', 'nvarchar(max)'), N'-- No missing fields found; nothing to generate.' + CHAR(13) + CHAR(10));

SELECT @RunId AS RunId, @FixScript AS FixScript;

----------------------------------------------------------------------
-- 4. Optionally halt the pipeline if any missing field is found
----------------------------------------------------------------------
IF @FailOnMissing = 1 AND EXISTS (SELECT 1 FROM #Findings)
BEGIN
        DECLARE @RunIdStr varchar(36) = CAST(@RunId AS varchar(36));
        RAISERROR('Preflight check found missing fields in target. Halting pipeline for review. RunId = %s.', 16, 1, @RunIdStr);
END;
END;
GO
