/*
 * Copyright (c) 2011-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
id,
category,
count(*) as totalCases

FROM study.cases a
WHERE a.isActive = true
GROUP BY a.id, a.category
HAVING count (*) > 1

