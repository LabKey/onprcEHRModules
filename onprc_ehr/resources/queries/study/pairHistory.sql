/*
 * Copyright (c) 2010-2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
PARAMETERS(StartDate TIMESTAMP)

SELECT
  h.Id,
  h.RoommateId,
  min(h.StartDate) as minDate,
  max(p.date) as mostRecentStart,
  sum(DaysCoHoused) as daysCoHoused

FROM study.housingRoommates h
WHERE h.StartDate >= StartDate
GROUP BY h.Id, h.roommateId

UNION ALL

SELECT
  p.Id,
  p2.Id as roommateId,
  min(p.date) as minDate,
  max(p.date) as maxDate,
  null as daysCoHoused

FROM study.pairings p
JOIN study.pairings p2 ON (p.pairId = p2.pairId AND p.pairId IS NOT NULL AND p.Id != p2.Id)
WHERE p.date >= StartDate
GROUP BY p.Id, p2.Id