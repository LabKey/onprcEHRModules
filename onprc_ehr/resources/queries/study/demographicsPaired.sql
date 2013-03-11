SELECT
  h.id,
  h.room,
  pc.effectiveCage,

  count(distinct h2.id) as total,
  group_concat(distinct h2.id, ', ') as animals,

FROM study.housing h
LEFT JOIN ehr_lookups.pairedCages pc ON (h.room = pc.room and h.cage = pc.cage)

LEFT JOIN study.housing h2 ON (h.room = h2.room and (pc.effectiveCage = h2.cage OR (pc.effectiveCage IS NULL and h2.cage IS NULL)))

WHERE h.enddateCoalesced >= curdate() and h2.enddateCoalesced >= curdate()

GROUP BY h.id, h.room, pc.effectiveCage