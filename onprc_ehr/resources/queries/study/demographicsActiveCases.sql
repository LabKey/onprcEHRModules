SELECT
  p.Id,
  group_concat(p.category, char(10)) as categories,
  count(*) as total
FROM study.cases p
WHERE p.enddateCoalesced >= now()
GROUP BY p.id