SELECT
  s.subjectId,
  s.marker,
  s.ref_nt_name,
  s.position,
  s.category,
  GROUP_CONCAT(DISTINCT s.alleles, chr(10)) as allles,
  COUNT(DISTINCT s.alleles) as distinctResults,
  COUNT(s.run) as totalRuns,
  SUM(totalResults) as totalDataPoints

FROM snpSummary s

GROUP BY s.subjectId, s.marker, s.ref_nt_name, s.position, s.category

HAVING COUNT(DISTINCT s.alleles) > 1