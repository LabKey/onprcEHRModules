SELECT
  p.Id,
  p.date,
  p.parent,
  p.relationship,
  p.method

FROM study.parentage p
--WHERE p.enddateCoalesced <= curdate()

UNION ALL

SELECT
  b.Id,
  b.date,
  b.dam,
  'Dam' as relationship,
  'Observed' as method

FROM study.birth b
WHERE b.dam is not null