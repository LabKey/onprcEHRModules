SELECT
  a.id,
  group_concat(DISTINCT a.project.name, chr(10)) as projects,
  group_concat(DISTINCT a.project.investigatorId.lastName, chr(10)) as investigators,
  count(distinct a.project.name) as totalProjects,
  count(*) as numActiveAssignments

FROM study.assignment a
WHERE a.enddateCoalesced >= curdate()
GROUP BY a.id