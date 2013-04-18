SELECT
  h.room,
  group_concat(DISTINCT h.Id.viral_status.viralStatus, chr(10)) as viralStatuses,
  count(DISTINCT h.Id.viral_status.viralStatus) as distinctStatuses

FROM study.housing h
WHERE h.enddateTimeCoalesced >= now()
GROUP BY h.room


