/*
 * Copyright (c) 2016-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
rowid,
owner.DisplayName AS owner,
created
FROM sla.purchaseDrafts
WHERE owner = userid()