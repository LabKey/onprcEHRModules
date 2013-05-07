SELECT
  d.id,
  coalesce(p2.parent, b.dam) as dam,
  CASE
    WHEN p2.parent IS NOT NULL THEN 'Genetic'
    WHEN b.dam IS NOT NULL THEN 'Observed'
    ELSE null
  END as damType,

  coalesce(p1.parent, b.sire) as sire,
  CASE
    WHEN p1.parent IS NOT NULL THEN 'Genetic'
    WHEN b.sire IS NOT NULL THEN 'Observed'
    ELSE null
  END as sireType,
  CASE
    WHEN (coalesce(p2.parent, b.dam) IS NOT NULL AND coalesce(p1.parent, b.sire) IS NOT NULL) THEN 2
    WHEN (coalesce(p2.parent, b.dam) IS NOT NULL OR coalesce(p1.parent, b.sire) IS NOT NULL) THEN 1
    ELSE 0
  END as numParents
FROM study.demographics d

LEFT JOIN (
  select p1.id, max(p1.parent) as parent
  FROM study.parentage p1
  WHERE p1.method = 'Genetic' AND p1.relationship = 'Sire' --AND p1.enddate IS NULL
  GROUP BY p1.Id
) p1 ON (d.Id = p1.id)
LEFT JOIN (
  select p2.id, max(p2.parent) as parent
  FROM study.parentage p2
  WHERE p2.method = 'Genetic' AND p2.relationship = 'Dam' --AND p2.enddate IS NULL
  GROUP BY p2.Id
) p2 ON (d.Id = p2.id)
LEFT JOIN study.birth b ON (b.id = d.id)

