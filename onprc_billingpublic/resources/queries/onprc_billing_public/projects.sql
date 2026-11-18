/*
 * Copyright (c) 2013-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  t.project,
  cast(p.title as varchar(200)) as title,
  ' [By Invoice]' as summaryByInvoice,
  ' [All Items]' as allItems

FROM publicInvoicedItems t left join pf_publicEhr.project p on t.project = p.project
WHERE t.project is not null
GROUP BY t.project, p.title