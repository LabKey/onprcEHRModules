Select
    Id,
    housingattime.roomattime + ' ' + housingattime.cageattime as location,
    date,
    enddate,
    flag.category as Category,
    flag.value as Meaning,
    remark,
    performedby,
    qcstate,
    taskid
From study.flags