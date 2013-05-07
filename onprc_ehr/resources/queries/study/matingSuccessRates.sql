SELECT
  m.Id,
  count(m.id) as totalMatings,
  sum(CASE
    WHEN m.births > 0 THEN 1
    ELSE 0
  END) as totalSuccessful
FROM study.matingOutcome m
GROUP BY m.id

UNION ALL

SELECT
  m.male as Id,
  count(m.male) as totalMatings,
  sum(CASE
    WHEN m.births > 0 THEN 1
    ELSE 0
  END) as totalSuccessful
FROM study.matingOutcome m
GROUP BY m.male