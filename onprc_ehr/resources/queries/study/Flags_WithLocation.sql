/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Select
    Id,
--     housingattime.roomattime + ' ' + housingattime.cageattime as location,
--     id.curLocation.room + ' ' +  id.curLocation.cage as location,
    CASE
        WHEN id.curLocation.cage is null THEN id.curLocation.room
        ELSE (id.curLocation.room || '-' || id.curLocation.cage)
        END AS Location,
    date,
    enddate,
    flag.category as Category,
    flag.value as Meaning,
    remark,
    performedby,
    qcstate,
    taskid
From study.flags