/*
 * Copyright (c) 2010-2012 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
--this query provides an overview of the MHC SSP results
SELECT
  s.subjectId,
  s.date,
  s.category,
  s.testName,
  s.run,
  max(s.result) as result,
  max(RowId) as rowId
FROM (
  SELECT
    s.subjectId,
    s.date,
    s.category,
    s.testName,
    s.run.rowid as run,
--     s.result,
--     s.resultOORIndicator,
    CASE
      WHEN s.resultOORIndicator IS NULL THEN cast(s.result as varchar)
      ELSE (s.resultOORIndicator || cast(s.result as varchar))
    END as result,
    s.RowId
  FROM Data s
) s

GROUP BY s.subjectId, s.date, s.testName, s.category, s.run
PIVOT result BY testName