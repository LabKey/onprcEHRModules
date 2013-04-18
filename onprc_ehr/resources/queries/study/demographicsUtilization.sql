SELECT
  t.Id,
  group_concat(DISTINCT t.use, chr(10)) as use,
  group_concat(DISTINCT t.category, chr(10)) as usageCategories

FROM (

SELECT
  a.Id,
  a.project.investigatorId.lastName || ' [' || a.project.name || ']' as use,
  'Research' as category
FROM study.assignment a
WHERE a.enddateCoalesced >= curdate()

UNION ALL

SELECT
  a.Id,
  a.groupId.name,
  a.groupId.category as category

FROM ehr.animal_group_members a
WHERE a.enddateCoalesced >= curdate()

) t

GROUP BY t.Id