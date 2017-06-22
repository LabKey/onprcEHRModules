/*
 * Copyright (c) 2013-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
pvt.*,
grp.servicerequested,
grp.remark,
grp.runRemark
FROM
(SELECT
  b.id,
  b.date,
  b.method,
  b.chargetype,
  b.testId,
  b.runId @hidden,
  group_concat(b.result) as results

  FROM (

  SELECT
    b.id,
    b.date,
    b.testId,
    b.runid.method as method,
    b.runid.chargetype as chargetype,
    coalesce(b.runId, b.objectid) as runId,
    CASE
    WHEN b.result IS NULL THEN  b.qualresult
      ELSE CAST(CAST(b.result AS float) AS VARCHAR)
    END as result
  FROM study."Hematology Results" b
  WHERE b.testId.includeInPanel = true and b.qcstate.publicdata = true
  ) b

GROUP BY b.id, b.date, b.runId, b.testId, b.method, b.chargetype
PIVOT results BY testId IN
(select testid from ehr_lookups.hematology_tests t WHERE t.includeInPanel = true)) pvt

LEFT OUTER JOIN

(SELECT
  b.id,
  b.date,
  group_concat(distinct servicerequested, chr(10)) as servicerequested,
  b.runId,
  b.method,
  b.chargetype,
  group_concat(distinct b.remark, chr(10)) as remark,
  group_concat(distinct b.runRemark, chr(10)) as runRemark

FROM (

  SELECT
    b.id,
    b.date,
    b.runid.method as method,
    b.runid.chargetype as chargetype,
    b.runid.servicerequested as servicerequested,
    coalesce(b.runId, b.objectid) as runId,
    b.remark,
    b.runId.remark as runRemark
  FROM study."Hematology Results" b
  WHERE b.testId.includeInPanel = true and b.qcstate.publicdata = true
) b

GROUP BY b.id, b.date, b.runId, b.method, b.chargetype) grp

ON pvt.id = grp.id AND pvt.date = grp.date AND pvt.runID = grp.runId AND pvt.method = grp.method AND pvt.chargetype = grp.chargetype