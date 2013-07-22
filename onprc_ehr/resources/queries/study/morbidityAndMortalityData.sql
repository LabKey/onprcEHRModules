SELECT
  p.lsid,
  p.Id,
  p.dateOnly as date,
  p.enddate,
  p.enddateCoalesced,
  p.category,
  p.history,
FROM study.problem p

UNION ALL

SELECT
  d.lsid,
  d.Id,
  d.dateOnly as date,
  d.date as enddate,
  d.dateOnly as enddateCoalesced,
  cast(('Death: ' || d.cause) as varchar) as category,
  d.history,
FROM study.deaths d
