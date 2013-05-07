SELECT
  t.room,
  t.category,
  t.totalIdsInRoom as totalIds,
  t.totalIdWithProblems,
  t.totalProblems,
  truncate(round((cast(t.totalIdWithProblems as double) / t.totalIdsInRoom) * 100.0, 2), 2) as pctWithProblem,

  t.startDate,
  t.endDate,

FROM (

SELECT
  t1.room,
  t1.category,
  count(distinct t1.problemId) as totalIdWithProblems,
  count(t1.problemId) as totalProblems,
  --(select count(distinct m.id) FROM study.housing m WHERE (m.dateOnly <= max(t1.EndDate) AND m.enddateCoalesced >= max(t1.StartDate) AND m.room = t1.room)) as totalIdsInRoom,
  max(t1.totalIdsInRoom) as totalIdsInRoom,
  max(t1.StartDate) as StartDate,
  max(t1.EndDate) as EndDate,

FROM study.roomProblemData t1
GROUP BY t1.room, t1.category

) t