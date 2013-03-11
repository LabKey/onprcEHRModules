SELECT
  p.Id,
  group_concat(p.category, char(10)) as problems,
  count(*) as totalProblems
FROM study.problem p
WHERE p.enddateCoalesced >= now()
GROUP BY p.id