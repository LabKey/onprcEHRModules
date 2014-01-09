/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
b.id,
b.date,
--b.runId,
b.method,
b.chargetype,
group_concat(distinct b.remark, chr(10)) as remark,
group_concat(distinct b.runRemark, chr(10)) as runRemark,
b.testId,
group_concat(b.result) as results

FROM (

SELECT
  b.id,
  b.date,
  b.testId,
  b.method,
  b.runid.chargetype as chargetype,
  coalesce(b.runId, b.objectid) as runId,
  b.remark,
  b.runId.remark as runRemark,
  b.resultoorindicator,
  CASE
  WHEN b.result IS NULL THEN  b.qualresult
    ELSE CAST(CAST(b.result AS float) AS VARCHAR)
  END as result
FROM study."Hematology Results" b
WHERE b.testId.includeInPanel = true and b.qcstate.publicdata = true

) b

GROUP BY b.id, b.date, b.runId, b.remark, b.testId, b.method, b.chargetype, b.runRemark
PIVOT results BY testId IN
(select testid from ehr_lookups.hematology_tests t WHERE t.includeInPanel = true)

