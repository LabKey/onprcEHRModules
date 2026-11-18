/*
 * Copyright (c) 2014-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
s.Id,
s.date,
s.project,
s.procedureId

FROM onprc_ssu.schedule s
LEFT JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.encounters e
  ON (s.Id = e.Id AND s.procedureId = e.procedureId AND CAST(s.date AS DATE) = e.dateOnly)
WHERE e.lsid IS NULL
