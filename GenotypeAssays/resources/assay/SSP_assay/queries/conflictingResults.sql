/*
 * Copyright (c) 2010-2012 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  m.subjectId,
  m.PrimerPair.ref_nt_name as ref_nt,

  group_concat(DISTINCT m.PrimerPair) AS PrimerPairs,
  group_concat(DISTINCT m.PrimerPair.ShortName) AS ShortName,
  count(*) as TotalRecords,

FROM Data m
WHERE m.result != 'FAIL' and m.result != 'IND'
GROUP BY m.subjectId, m.PrimerPair.ref_nt_name
HAVING max(m.Result) != min(m.result)