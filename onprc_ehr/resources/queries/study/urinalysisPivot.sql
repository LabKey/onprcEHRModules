/*
 * Copyright (c) 2013-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
pvt.*,
grp.remark
FROM
  (SELECT
    b.id,
    b.date,
    b.method,
    b.collectionmethod,
    b.testId,
    b.runId @hidden,
    group_concat(b.results) as results

    FROM (

      SELECT
        b.id,
        b.date,
        b.testId,
        coalesce(b.runId, b.objectid) as runId,
        b.remark,
        b.method,
        b.runid.collectionmethod,
        b.results
      FROM study."Urinalysis Results" b
      WHERE b.testId.includeInPanel = true and b.qcstate.publicdata = true
      ) b

    GROUP BY b.id, b.date, b.runId, b.testId, b.method, b.collectionmethod, b.remark
    PIVOT results BY testId IN (select testid from ehr_lookups.urinalysis_tests t WHERE t.includeInPanel = true order by sort_order)
    ) pvt

  LEFT OUTER JOIN

   (SELECT
    b.id,
    b.date,
    b.method,
    b.collectionmethod,
    b.runId,
    group_concat(distinct b.remark, chr(10)) as remark,

    FROM (

      SELECT
        b.id,
        b.date,
        coalesce(b.runId, b.objectid) as runId,
        b.remark,
        b.method,
        b.runid.collectionmethod,
      FROM study."Urinalysis Results" b
      WHERE b.testId.includeInPanel = true and b.qcstate.publicdata = true
      ) b

    GROUP BY b.id, b.date, b.runId, b.method, b.collectionmethod, b.remark
    ) grp

  ON pvt.id = grp.id AND pvt.date = grp.date AND pvt.method = grp.method AND pvt.runId = grp.runId AND pvt.collectionmethod = grp.collectionmethod
