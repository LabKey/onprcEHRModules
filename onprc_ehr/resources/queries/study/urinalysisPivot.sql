/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  b.id,
  b.date,
  b.method,
  group_concat(distinct b.remark, chr(10)) as remark,
  b.testId,
  group_concat(b.results) as results

FROM (

SELECT
  b.id,
  b.date,
  b.testId,
  coalesce(b.runId, b.objectid) as runId,
  b.remark,
  b.method,
  b.results
FROM study."Urinalysis Results" b

WHERE b.testId.includeInPanel = true and b.qcstate.publicdata = true
) b

GROUP BY b.id, b.date, b.runId, b.testId, b.method, b.remark
PIVOT results BY testId IN ('Color', 'App', 'SpecGrav', 'pH', 'Bili', 'Glu', 'Ket', 'Prot', 'Urobili', 'Bact', 'Blood', 'WBC', 'RBC', 'Epith', 'Crystals', 'Casts', 'Cast-1', 'Cast-2')

