SELECT
  c.room,
  c.cage_type,
  count(*) as total

FROM ehr_lookups.cage c
WHERE c.cage_type != 'No Cage'
GROUP BY c.room, c.cage_type