SELECT
  d.groupId,
  d.Id,
  avg(k.coefficient) as avgCoefficient,
  count(k.Id2) as distinctAnimals

FROM ehr.animal_group_members d
JOIN ehr.kinship k ON (d.Id = k.Id)
JOIN ehr.animal_group_members d2 ON (d2.Id = k.Id2 and d.groupId = d2.groupId)

WHERE
  d.enddateCoalesced >= curdate() and
  d2.enddateCoalesced >= curdate() and
  d.date <= now() and
  d2.date <= now()

GROUP BY d.groupId, d.Id
