SELECT
  p.rowid,
  p.protocol,
  p.project,
  count(p2.rowid) as totalOverlapping,
  group_concat(distinct p2.rowid, ';') as overlapping

FROM ehr.protocol_counts p
JOIN ehr.protocol_counts p2 ON (
    (p.protocol = p2.protocol OR p.project = p2.project) AND
    (p.rowid != p2.rowid) AND
    (p.start <= p2.enddateCoalesced AND p.enddateCoalesced >= p2.start) AND
    (p.species = p2.species OR (p.species IS NOT NULL AND p2.species IS NULL)) AND
    (p.gender = p2.gender OR (p.gender IS NOT NULL AND p2.gender IS NULL))
)

GROUP BY p.rowid, p.protocol, p.project