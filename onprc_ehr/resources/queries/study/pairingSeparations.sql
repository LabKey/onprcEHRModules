SELECT
  p1.Id,
  p1.date,
  p1.eventtype,
  TIMESTAMPDIFF('SQL_TSI_DAY', curdate(), p1.date) as daysSinceEvent

FROM study.pairings p1
JOIN study.pairings p2 ON (p1.Id = p2.Id AND p2.date > p1.date AND p2.eventtype IN ('Reunite', 'Permanent separation'))
WHERE p1.eventType = 'Temporary separation' AND TIMESTAMPDIFF('SQL_TSI_DAY', curdate(), p1.date) > 7 AND p2.Id IS NULL

UNION ALL

SELECT
  p1.Id,
  p1.date,
  p1.eventtype,
  TIMESTAMPDIFF('SQL_TSI_DAY', curdate(), p1.date) as daysSinceEvent

FROM study.pairings p1
JOIN study.pairings p2 ON (p1.Id = p2.Id AND p2.date > p1.date AND p2.eventtype IN ('Reunite', 'Permanent separation'))
WHERE p1.eventType = 'Extended temporary separation' AND TIMESTAMPDIFF('SQL_TSI_DAY', curdate(), p1.date) > 30 AND p2.Id IS NULL