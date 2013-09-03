SELECT
  d.subjectId,
  d.run.method as method,
  count(*) as totalResults,
  count(distinct d.run) as totalRuns,

FROM Data d

GROUP BY d.subjectId, d.run.method