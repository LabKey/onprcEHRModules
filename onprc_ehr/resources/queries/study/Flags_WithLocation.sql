Select
    Id,
    housingattime.roomattime + ' ' + housingattime.cageattime as location,
    date,
    enddate,
    category,
    value,
    remark,
    performedby,
    qcstate,
    taskid
From study.flags