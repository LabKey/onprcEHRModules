SELECT
  h1.id,
  h2.id as dam,
  h1.room,
  h1.cage,
  h1.id.age.ageInDays,

FROM study.housing h1
JOIN study.housing h2 ON (h1.id.parents.dam = h2.id AND h1.room = h2.room AND (h1.cage = h2.cage OR (h1.cage IS NULL AND h2.cage IS NULL)))
WHERE h1.enddateTimeCoalesced >= now() AND h2.enddateTimeCoalesced >= now()