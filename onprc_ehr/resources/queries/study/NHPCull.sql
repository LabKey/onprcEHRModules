SELECT flags.Id,
flags.date,
flags.flag,
flags.performedby,
flags.remark,
flags.taskid,
flags.description,
flags.RequestedBY,
flags.TargetEndDate,
flags.ScheduleNecropsy,
flags.history
FROM flags join demographics d on flags.id = d.id
where flags.flag.value like '%Cull%' and d.calculated_Status = 'alive' and flags.enddate is null