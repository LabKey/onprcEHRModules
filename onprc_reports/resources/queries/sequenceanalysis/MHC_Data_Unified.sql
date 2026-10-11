/*
 * Copyright (c) 2013-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT

  t.subjectId as Id,
  t.marker as allele,
  null as shortName,
  sum(t.totalTests) as totalTests,
  t.result,
  GROUP_CONCAT(distinct t.assaytype) as type,
  GROUP_CONCAT(distinct t.libraryType) as libraryTypes

FROM geneticscore.mhc_data t
GROUP BY t.subjectid, t.marker, t.result
