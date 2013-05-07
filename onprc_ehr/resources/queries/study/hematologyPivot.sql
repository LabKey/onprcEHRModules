/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
b.id,
b.date,
b.method,
b.testId,
group_concat(b.result) as results

FROM (

SELECT
  b.id,
  b.date,
  b.testId,
  b.method,
  coalesce(b.runId, b.objectid) as runId,
  b.resultoorindicator,
  CASE
  WHEN b.result IS NULL THEN  b.qualresult
    ELSE CAST(CAST(b.result AS float) AS VARCHAR)
  END as result
FROM study."Hematology Results" b
WHERE b.testId.includeInPanel = true and b.qcstate.publicdata = true

) b

GROUP BY b.id, b.date, b.runId, b.testId, b.method
PIVOT results BY testId IN
('WBC','LYMPH','NEUT','Bands','BAS','EO','MONO','HCT','RBC','Hg','MCV','MCHC','MCH','RETIC','PLT')
--sadly we need to display the columns in the specific order, so rather than keying off the DB we need to hard code
--(select testid from ehr_lookups.hematology_tests t WHERE t.includeInPanel = true)

