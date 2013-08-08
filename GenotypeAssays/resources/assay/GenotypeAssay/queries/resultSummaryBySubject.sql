SELECT
  d.subjectId,
  d.run.assayType,
  count(*) as totalResults,
  count(distinct d.run) as totalRuns,

FROM Data d

GROUP BY d.subjectId, d.run.assayType