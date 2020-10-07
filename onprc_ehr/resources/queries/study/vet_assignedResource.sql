SELECT a.Id,
a.project,
a.project.use_category,
a.project.protocol,
a.date,
a.projectedRelease,
a.enddate,
a.assignCondition,
'Resource Assigned' as ProtocolType
FROM study.assignment a
where ((a.date <= Now() and a.enddate is null) and (a.project.use_category != 'Research'))