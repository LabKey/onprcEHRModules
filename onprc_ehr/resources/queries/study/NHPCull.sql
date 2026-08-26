SELECT f.Id,
f.date,
f.flag,
f.performedby,
f.remark,
f.taskid,
f.description,
f.RequestedBY,
f.TargetEndDate,
f.ScheduleNecropsy,
f.history
FROM flags f join demographics d on f.id = d.id
where f.flag.value like '%Cull%' and d.calculated_Status = 'alive' and f.enddate is null