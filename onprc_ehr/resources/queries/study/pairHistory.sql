/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
PARAMETERS(StartDate TIMESTAMP)

SELECT
  h.Id,
  h.RoommateId,
  'Housing Record' as category,
  min(h.RoommateStart) as earliestOverlap,
  max(h.RoommateEnd) as mostRecentOverlap,
  sum(DaysCoHoused) as daysCoHoused,
  null as eventType,
  null as goal,
  null as observation,
  null as outcome,
  null as remark,
  null as pairId,
  null as taskid

FROM study.housingRoommates h
WHERE h.StartDate >= StartDate and h.room.housingType.value = 'Cage Location'
GROUP BY h.Id, h.roommateId

UNION ALL

SELECT
  p.Id,
  (SELECT group_concat(distinct p2.Id, chr(10)) FROM study.pairings p2 WHERE p.Id != p2.id AND p.pairId = p2.pairId) as roommateId,
  'Pairing Record' as category,
  p.date as earliestOverlap,
  null as mostRecentOverlap,
  null as daysCoHoused,
  p.eventType,
  p.goal,
  p.observation,
  p.outcome,
  p.remark,
  p.pairId,
  p.taskid

FROM study.pairings p
WHERE p.date >= StartDate