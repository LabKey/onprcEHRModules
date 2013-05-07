SELECT
  pc.protocol,
  pc.project,
  pc.species,
  pc.gender,
  pc.start,
  pc.enddate,
  pc2.totalAssignments,
  pc.allowed,
  pc2.totalAnimals,
  CASE
    WHEN pc.allowed > 0 THEN ((pc2.totalAnimals / CAST(pc.allowed as double)) * 100)
    ELSE null
  END as pctUsed

FROM ehr.protocol_counts pc
LEFT JOIN (
  SELECT pc.rowid, count(a.lsid) as totalAssignments, count(DISTINCT a.Id) as totalAnimals
  FROM ehr.protocol_counts pc
  JOIN study.assignment a ON (
    (a.dateOnly < pc.enddateCoalesced AND a.enddateCoalesced >= pc.start) AND
    (pc.protocol IS NULL OR pc.protocol = a.project.protocol) AND
    (pc.project IS NULL OR pc.project = a.project) AND
    (pc.species IS NULL OR pc.species = a.Id.demographics.species) AND
    (pc.gender IS NULL OR pc.gender = a.Id.demographics.gender)
  )
  GROUP BY pc.rowid
) pc2 ON (pc.rowid = pc2.rowid)