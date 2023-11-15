/*
 * Copyright (c) 2011-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
-- Modified: 11-15-2023 R. Blasa
SELECT
id,
category,
count(*) as totalCases

FROM study.cases a
WHERE a.isActive = true
And a.category = 'Clinical'
GROUP BY a.id, a.category
HAVING count (*) > 1

