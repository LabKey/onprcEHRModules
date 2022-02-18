Select
    Id,
--     housingattime.roomattime + ' ' + housingattime.cageattime as location,
--     id.curLocation.room + ' ' +  id.curLocation.cage as location,
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