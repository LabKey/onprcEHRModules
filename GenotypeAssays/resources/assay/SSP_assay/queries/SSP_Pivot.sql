/*
 * Copyright (c) 2010-2012 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
--this query provides an overview of the MHC SSP results
SELECT
  s.subjectId,
  s.PrimerPair.ref_nt_name as allele,
  CASE
    WHEN (max(s.Result)=min(s.result))
      THEN max(s.Result)
    ELSE 'DISCREPANCY'
  END
  AS result

FROM Data s

GROUP BY s.subjectId, s.PrimerPair.ref_nt_name
PIVOT result BY allele