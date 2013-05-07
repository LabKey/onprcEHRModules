SELECT
  t.groupCategory,
  t.category,
  t.totalIdsInCategory as totalIds,
  t.totalIdWithProblems,
  t.totalProblems,
  truncate(round((cast(t.totalIdWithProblems as float) / t.totalIdsInCategory * 100.0), 2), 2) as pctWithProblem,
  t.startDate,
  t.endDate,

FROM (

SELECT
  g.category as groupCategory,
  t1.category,
  count(distinct t1.problemId) as totalIdWithProblems,
  count(t1.problemId) as totalProblems,

  max(t1.StartDate) as StartDate,
  max(t1.EndDate) as EndDate,
  (select count(distinct m.id) FROM ehr.animal_group_members m WHERE (m.date <= max(t1.EndDate) AND m.enddateCoalesced >= max(t1.StartDate) AND m.groupId.category = g.category)) as totalIdsInCategory

FROM study.animalGroupProblemData t1
JOIN ehr.animal_groups g ON (t1.groupId = g.rowid)
GROUP BY g.category, t1.category

) t