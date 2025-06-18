/****** Object:  StoredProcedure [audit].[GetAuditTables]
  *Update to puish 2025-0618
Script Date: 6/17/2025 1:40:29 PM ******/
 */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [audit].[GetAuditTables]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
@SourceDB NVARCHAR(128) = 'Labkey_next_GJ',
        @SchemaName NVARCHAR(128) = 'audit',
        @SQL NVARCHAR(MAX);

    SET @SQL = '
    SELECT
        t.TABLE_NAME,
        p.[rows] AS RowCount
    FROM ' + QUOTENAME(@SourceDB) + '.INFORMATION_SCHEMA.TABLES t
    JOIN ' + QUOTENAME(@SourceDB) + '.sys.partitions p
        ON OBJECT_ID(' + QUOTENAME(@SourceDB) + ' + ''.'' + t.TABLE_SCHEMA + ''.'' + t.TABLE_NAME) = p.OBJECT_ID
    WHERE
        t.TABLE_SCHEMA = @SchemaName
        AND p.index_id IN (0,1) -- heap or clustered index
    GROUP BY
        t.TABLE_NAME, p.[rows]';

EXEC sp_executesql @SQL, N'@SchemaName NVARCHAR(128)', @SchemaName;
END;
