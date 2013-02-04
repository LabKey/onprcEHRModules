SELECT
  a.id,
  group_concat(DISTINCT a.project.name, chr(10)) as projects,
  group_concat(DISTINCT a.project.investigatorId.lastName, chr(10)) as investigators,
  count(distinct a.project.name) as totalProjects

FROM study.assignment a
GROUP BY a.id