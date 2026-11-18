/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
r.Id,
r.name as resourceid,
r.color,
r.room,
r.bldg,
r.Container,
c.name as FolderName
FROM Resources r, core.Containers c
Where c.EntityId = r.container
And c.name like 'PMIC Scheduler'

