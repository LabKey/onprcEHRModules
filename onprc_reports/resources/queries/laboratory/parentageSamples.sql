/*
 * Copyright (c) 2013-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
s.subjectId,
s.sampletype,
s.quantity

FROM laboratory.samples s
WHERE s.container = '438EA075-CCA5-1031-BD48-5107380A722C' AND dateremoved is null