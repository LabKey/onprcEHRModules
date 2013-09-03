SELECT
  b.taskId,
  b.requestId,
  b.Id,
  b.dateOnly,
  coalesce(b.tube_type, 'Not Specified') as tube_type,
  sum(b.quantity) as totalVol

FROM study.blood b

WHERE b.qcstate.publicdata = false
GROUP BY b.taskId, b.requestId, b.Id, b.dateOnly, coalesce(b.tube_type, 'Not Specified')
PIVOT totalVol by tube_type