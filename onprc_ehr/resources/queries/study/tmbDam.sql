/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
--Update 3/11/2019 Added to Test

SELECT a.Id,
a.id.demographics.gender,
a.project,
a.date,
a.projectedRelease,
a.enddate

FROM assignment a where a.project = 559 and enddate is null