SELECT
  p.Id,
 (SELECT group_concat(distinct p2.Id, chr(10)) FROM study.pairings p2 WHERE p.Id != p2.id AND p.pairId = p2.pairId) as otherIds,
  p.pairid,
  p.date,
  p.lowestCage,
  p.room,
  p.cage,
  p.eventType,
  p.goal,
  p.observation,
  p.outcome,
  p.separationreason,
  p.remark,
  p.remark2,
  p.enddate,
  p.endeventType,
  p.performedby,
  p.taskid,
  TIMESTAMPDIFF('SQL_TSI_DAY', p.date, coalesce(p.enddate,curdate())) as duration,
  p.qcstate

FROM study.pairings p
where p.eventtype in ('General Comment', 'Pair monitor')