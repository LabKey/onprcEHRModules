SELECT *
FROM study.AssignmentsInRange a
WHERE project NOT IN ('0300','0456')   -- resource exemptions (TMB/Aging)
