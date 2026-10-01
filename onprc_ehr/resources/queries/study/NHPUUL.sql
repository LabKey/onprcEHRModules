SELECT f.Id,
f.date,
f.enddate,
f.flag,
f.performedby,
f.remark,
f.taskid,
f.description,
f.RequestedBY,
f.ScheduleNecropsy,
f.history
FROM flags f join demographics d on f.id = d.id
where f.flag.value like '%Underutilized%' and d.calculated_status = 'alive' and f.enddate is null