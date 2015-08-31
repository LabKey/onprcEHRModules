/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
b.Id,
b.date,
b.method,
group_concat(distinct b.remark, chr(10)) as remark,
group_concat(distinct b.runRemark, chr(10)) as runRemark,
b.testId,
group_concat(b.result) as results

FROM (

SELECT
  b.Id,
  b.date,
  b.testId,
  coalesce(b.runId, b.objectid) as runId,
  --NOTE: removed to allow legacy runs to group into 1 row.  since we already group on Id/Date/Test, this should be ok
  --coalesce(b.taskId, b.runId) as groupingId,
  b.runid.method as method,
  b.remark,
  b.runId.remark as runRemark,
  b.resultoorindicator,
  CASE
  WHEN b.result IS NULL THEN  b.qualresult
    ELSE CAST(CAST(b.result AS float) AS VARCHAR)
  END as result
FROM study."Chemistry Results" b
WHERE b.testId.includeInPanel = true and b.qcstate.publicdata = true

) b

--Updated 6-3-2015 Blasa
GROUP BY b.runid,b.id, b.date, b.testId, b.method


PIVOT results BY testId IN

(select testid from ehr_lookups.chemistry_tests t WHERE t.includeInPanel = true order by sort_order)

