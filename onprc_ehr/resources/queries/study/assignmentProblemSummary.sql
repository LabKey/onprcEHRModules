SELECT
  t.project,
  t.category,
  t.totalIds,
  t.totalIdWithProblems,
  t.totalProblems,

  t.startDate,
  t.endDate,

  truncate(round((cast(t.totalIdWithProblems as double) / t.totalIds) * 100.0, 2), 2) as pctWithProblem,

FROM (

SELECT
  t1.project,
  t1.category,
  (select count(distinct m.id) FROM study.assignment m WHERE (m.date <= max(t1.EndDate) AND m.enddateCoalesced >= max(t1.StartDate) AND m.project = t1.project) GROUP BY m.project) as totalIds,
  count(distinct t1.problemId) as totalIdWithProblems,
  count(t1.problemId) as totalProblems,

  max(t1.StartDate) as StartDate,
  max(t1.EndDate) as EndDate,

FROM study.assignmentProblemData t1
GROUP BY t1.project, t1.category

) t