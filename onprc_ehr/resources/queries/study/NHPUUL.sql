SELECT flags.Id,
flags.date,
flags.enddate,
flags.flag,
flags.performedby,
flags.remark,
flags.taskid,
flags.description,
flags.RequestedBY,
flags.ScheduleNecropsy,
flags.TargetEndDate,
flags.history
FROM flags join demographics d on flags.id = d.id
where flags.flag.value like '%Underutilized%' and d.calculated_status = 'alive' and flags.enddate is null