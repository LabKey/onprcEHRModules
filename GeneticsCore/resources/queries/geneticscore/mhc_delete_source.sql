SELECT
q.RowPk,
q.created,
q.createdby,
q.created as modified,
q.createdby as modifiedby,
q.Container

FROM auditLog.QueryUpdateAuditEvent q
WHERE q.SchemaName = 'geneticscore' and q.QueryName = 'mhc_data' and q.comment = 'A row was deleted.'