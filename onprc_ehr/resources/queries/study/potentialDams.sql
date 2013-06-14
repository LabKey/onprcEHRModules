SELECT
  b.Id,
  b.date as birth,
  h.Id as potentialDam,
  b.room as birthRoom,
  b.cage as birthCage

FROM study.birth b

JOIN study.housing h ON (
    h.date <= b.date AND
    h.enddateCoalesced >= b.date AND
    h.room = b.room AND (h.cage = b.cage OR (h.cage is null and b.cage is null))
)

WHERE h.id.demographics.gender = 'f'
