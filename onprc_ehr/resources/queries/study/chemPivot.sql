/*
 * Copyright (c) 2013-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  pivot_.*,
  grp.remark,
  grp.runRemark
FROM
(SELECT
  b.runId @hidden,
  b.Id,
  b.date,
  b.method,
  b.chargetype,       ---Added 9-14-2015 Blasa
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
      b.runid.chargetype as chargetype,    ---Added 9-14-2015 Blasa
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
  GROUP BY b.runid,b.id, b.date, b.testId, b.method, b.chargetype
  PIVOT results BY testId IN (select testid from ehr_lookups.chemistry_tests t WHERE t.includeInPanel = true order by sort_order)) pivot_

LEFT OUTER JOIN

(SELECT
  group_concat(distinct d.remark, chr(10)) as remark,
  group_concat(distinct d.runRemark, chr(10)) as runRemark,
  d.runid,d.id, d.date, d.method, d.chargetype

  FROM (

    SELECT
      d.Id,
      d.date,
      coalesce(d.runId, d.objectid) as runId,
      --NOTE: removed to allow legacy runs to group into 1 row.  since we already group on Id/Date/Test, this should be ok
      --coalesce(b.taskId, b.runId) as groupingId,
      d.runid.method as method,
      d.runid.chargetype as chargetype,    ---Added 9-14-2015 Blasa
      d.remark,
      d.runId.remark as runRemark,
      d.resultoorindicator,
      CASE
      WHEN d.result IS NULL THEN  d.qualresult
        ELSE CAST(CAST(d.result AS float) AS VARCHAR)
      END as result
    FROM study."Chemistry Results" d
    WHERE d.testId.includeInPanel = true and d.qcstate.publicdata = true

    ) d

  --Updated 6-3-2015 Blasa
  GROUP BY d.runid,d.id, d.date, d.method, d.chargetype) grp

ON pivot_.runId = grp.runId AND pivot_.id = grp.id AND pivot_.date = grp.date AND pivot_.method = grp.method AND pivot_.chargetype = grp.chargetype

