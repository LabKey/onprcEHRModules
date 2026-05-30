/*
 * Copyright (c) 2016-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  s.subjectId as Id,
  count(s.subjectId) as totalSamples,
  group_concat(DISTINCT s.sampleType, chr(10)) as sampleTypes,

FROM DNA_Bank.samples s
GROUP BY s.subjectId