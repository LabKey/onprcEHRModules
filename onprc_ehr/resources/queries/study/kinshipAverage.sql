SELECT
  d.Id,
  avg(coalesce(k.coefficient, 0)) as avgCoefficient,
  count(k.Id2) as distinctRelatedAnimals,
  count(d2.Id) as distinctAnimals

FROM study.demographics d
JOIN study.demographics d2 ON (d.calculated_status = 'Alive' AND d2.calculated_status = 'Alive')

LEFT JOIN ehr.kinship k ON (d.Id = k.Id AND d2.Id = k.Id2)

GROUP BY d.Id
