SELECT
  m.Id,
  group_concat(m.groupId.name, chr(10)) as groups,
  count(m.groupId) as totalGroups

FROM ehr.animal_group_members m
WHERE m.isActive = true
GROUP BY m.Id
HAVING count(*) > 1
