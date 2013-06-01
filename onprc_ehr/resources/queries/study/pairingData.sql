SELECT
  p1.Id,
  p1.Id2,
  p1.date,
  p1.pairingType,
  p1.pairingOutcome,
  p1.separationReason,
  p1.aggressor,
  p1.room1,
  p1.cage1,
  p1.room2,
  p1.cage2,
  p1.remark,
  p1.performedby

FROM study.pairings p1

UNION ALL

SELECT
  p2.Id2 as Id,
  p2.Id as Id2,
  p2.date,
  p2.pairingType,
  p2.pairingOutcome,
  p2.separationReason,
  p2.aggressor,
  p2.room2 as room1,
  p2.cage2 as cage1,
  p2.room1 as room2,
  p2.cage1 as cage2,
  p2.remark,
  p2.performedby

FROM study.pairings p2
