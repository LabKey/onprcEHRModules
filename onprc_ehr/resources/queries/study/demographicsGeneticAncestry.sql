/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
d.Id,
group_concat(distinct d.result) as geneticAncestry

FROM study.geneticAncestry d
WHERE d.isActive = true
GROUP BY d.Id