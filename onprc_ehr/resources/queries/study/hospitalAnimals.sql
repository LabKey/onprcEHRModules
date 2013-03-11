SELECT
  h.Id,
  h.room,
  h.cage,
  h.duration

FROM study.housing h

WHERE h.room IN ('COL N W A', 'COL N W B', 'COL N W C', 'COL N W D', 'COL RM 2', 'COL RM 4')
AND h.enddateCoalesced >= now()