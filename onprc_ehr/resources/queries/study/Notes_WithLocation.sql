Select
    Id,
    housingattime.roomattime + ' ' + housingattime.cageattime as location,
    date,
    actiondate,
    enddate,
    category,
    value,
    remark,
    qcstate,
    taskid
From study.notes