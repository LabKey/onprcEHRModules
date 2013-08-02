SELECT
  t1.Id,
  group_concat(t1.category, chr(10)) as categories
FROM (
SELECT
  t.Id,
  cast((t.category || cast(' (' as varchar) || cast(t.total as varchar) || cast(')' as varchar)) as varchar(500)) as category

FROM (
SELECT
  p.Id,
  p.category,
  count(*) as total
FROM study."Problem List" p
WHERE p.daysElapsed <= 730
GROUP BY p.Id, p.category

) t

) t1
GROUP BY t1.id
