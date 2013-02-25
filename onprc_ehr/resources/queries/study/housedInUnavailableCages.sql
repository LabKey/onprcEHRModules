SELECT
  h.id,
  h.room,
  h.cage,
  h.date,
  h.enddate,
  c.cage_type,
  c.leftCage,
  c.left_cage_type,
  c.divider,
  c.isAvailable
FROM study.housing h
JOIN ehr_lookups.availableCages c ON (c.room = h.room AND c.cage = h.cage)

WHERE h.enddatetimeCoalesced >= now()

AND c.isAvailable = false