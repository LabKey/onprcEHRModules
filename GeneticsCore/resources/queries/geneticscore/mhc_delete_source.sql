/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
    q.RowPk as objectid,
    q.created,
    q.created as modified,
    q.Container

FROM AuditSummary.QueryUpdateAuditLog q
WHERE q.SchemaName = 'geneticscore' and q.QueryName = 'mhc_data' and q.comment in ('A row was deleted.', 'Row was deleted.')