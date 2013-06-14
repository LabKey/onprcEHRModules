SELECT
  c.Id,
  h.Id as potentialSire,
  group_concat(DISTINCT h.room) as rooms,
  group_concat(DISTINCT h.cage) as cages

FROM study.potentialConceptionLocations c

--then find all males overlapping with these locations that also overlap with the conception window
JOIN study.housing h ON (
    h.Id.demographics.gender = 'm' AND
    h.room = c.room AND
    (h.cage = c.cage OR (h.cage IS NULL AND c.cage IS NULL)) AND
    h.date <= c.maxDate AND h.enddateTimeCoalesced >= c.minDate
)

GROUP BY c.Id, h.Id