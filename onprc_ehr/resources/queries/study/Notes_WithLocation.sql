/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Select
    Id,
    CASE
        WHEN id.curLocation.cage is null then id.curLocation.room
        ELSE (id.curLocation.room || '-' || id.curLocation.cage)
        END AS Location,
    date,
    actiondate,
    enddate,
    category,
    value,
    remark,
    qcstate,
    taskid
From study.notes