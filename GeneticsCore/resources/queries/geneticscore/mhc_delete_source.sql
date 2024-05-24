SELECT
    q.RowPk as objectid,
    q.created,
    q.created as modified,
    q.Container

FROM AuditSummary.QueryUpdateAuditLog q
WHERE q.SchemaName = 'geneticscore' and q.QueryName = 'mhc_data' and q.comment in ('A row was deleted.', 'Row was deleted.')