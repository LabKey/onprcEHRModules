SELECT
  d.id,
  d.id.curLocation.room,
  d.id.curLocation.cage,
  d.id.age.ageInDays,

  d2.dam as dam,
  dl.room as damRoom,
  dl.cage as damCage,

FROM study.demographics d

LEFT JOIN study.demographicsParents d2 ON (d.id = d2.id)

LEFT JOIN study.demographicsCurrentLocation dl ON (d2.dam = dl.id)

WHERE d.id.curLocation.room != dl.room AND coalesce(d.id.curLocation.cage, '') != coalesce(dl.cage, '')