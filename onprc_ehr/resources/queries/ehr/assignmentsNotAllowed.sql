SELECT
  a.Id,
  a.project,
  a.project.protocol,
  a.date,
  a.enddate

FROM study.assignment a
LEFT JOIN ehr.protocol_counts pc ON (
  (a.dateOnly < pc.enddateCoalesced AND a.enddateCoalesced >= pc.start) AND
  (pc.protocol IS NULL OR pc.protocol = a.project.protocol) AND
  (pc.project IS NULL OR pc.project = a.project) AND
  ((pc.species IS NULL OR pc.species = a.Id.demographics.species) OR pc.species = 'UNIDENTIFIED MACAQUE' AND a.Id.demographics.species LIKE '%MACAQUE%') AND
  (pc.gender IS NULL OR pc.gender = a.Id.demographics.gender)
)

WHERE pc.rowid IS NULL