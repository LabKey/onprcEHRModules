/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
b.Id,
b.date,
b.method,
b.testId,
group_concat(b.result) as results

FROM (

SELECT
  b.Id,
  b.date,
  b.testId,
  coalesce(b.runId, b.objectid) as runId,
  b.method,
  --b.resultoorindicator,
  CASE
  WHEN b.result IS NULL THEN  b.qualresult
    ELSE CAST(CAST(b.result AS float) AS VARCHAR)
  END as result
FROM study.iStat b
WHERE b.testId.includeInPanel = true and b.qcstate.publicdata = true

) b

GROUP BY b.id, b.date, b.runId, b.testId, b.method
PIVOT results BY testId IN (select testid from ehr_lookups.istat_tests t WHERE t.includeInPanel = true order by sort_order)