SELECT
  p.lowestCage,
  p.room,
  p.taskId,
  count(*) as total,
  group_concat(p.Id) as Ids

FROM study.pairings p
WHERE taskId is not null
GROUP BY p.taskId, p.lowestCage, p.room
HAVING COUNT(distinct p.pairId) > 1