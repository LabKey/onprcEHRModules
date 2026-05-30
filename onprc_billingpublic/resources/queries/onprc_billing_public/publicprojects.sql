/*
 * Copyright (c) 2022-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  t.project,
  cast(t.project.title as varchar(200)) as title,
  ' [By Invoice]' as summaryByInvoice,
  ' [All Items]' as allItems

FROM publicInvoicedItems t
WHERE t.project is not null
GROUP BY t.project, t.project.title