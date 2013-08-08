/*
 * Copyright (c) 2010-2012 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
--this query provides an overview of the MHC SSP results
SELECT
  m.subjectId,
  m.PrimerPair.ref_nt_name as allele,

  group_concat(DISTINCT m.PrimerPair) AS PrimerPairs,
  group_concat(DISTINCT m.PrimerPair.ShortName) AS ShortName,
  count(*) as TotalRecords,

  CASE
    WHEN (max(m.Result)=min(m.result))
      THEN max(m.Result)
    ELSE 'DISCREPANCY'
  END
  AS Status

FROM Data m
WHERE m.result != 'FAIL' and m.result != 'IND'
GROUP BY m.subjectId, m.PrimerPair.ref_nt_name