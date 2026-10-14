/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT a.Id,
a.project,
a.project.use_category,
a.dateOnly,
a.endDateCoalesced
FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.assignment a
where a.enddate is Null and a.project.use_category like '%ESPF%'