SELECT
  s.subjectId,
  s.marker,
  s.category,
  GROUP_CONCAT(DISTINCT s.alleles, chr(10)) as allles,
  COUNT(DISTINCT s.alleles) as distinctResults,
  COUNT(s.run) as totalRuns,
  SUM(totalResults) as totalDataPoints

FROM strSummary s

GROUP BY s.subjectId, s.marker, s.category

HAVING COUNT(DISTINCT s.alleles) > 1