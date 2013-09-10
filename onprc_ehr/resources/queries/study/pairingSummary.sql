SELECT
  p.Id,
  (SELECT group_concat(distinct p2.Id, chr(10)) FROM study.pairings p2 WHERE p.Id != p2.id AND p.date = p2.date and p.room = p2.room and p.pairId = p2.pairId) as otherIds,
  p.date,
  p.eventType,
  p.housingType,
  p.observation,
  p.outcome,
  p.remark

FROM study.pairings p
