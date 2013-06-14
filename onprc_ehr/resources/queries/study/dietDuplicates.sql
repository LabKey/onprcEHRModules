SELECT
  d.Id

FROM study.diet d

GROUP BY d.Id
HAVING COUNT(*) > 1