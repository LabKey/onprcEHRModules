SELECT
  d.id,
  group_concat(DISTINCT a.project.name, chr(10)) as projects,
  group_concat(DISTINCT a.project.investigatorId.lastName, chr(10)) as investigators,
  COALESCE(count(distinct a.project.name), 0) as totalProjects,
  COALESCE(count(a.lsid), 0) as numAssignments

FROM study.demographics d
LEFT JOIN study.assignment a ON (a.id = d.id)
GROUP BY d.id