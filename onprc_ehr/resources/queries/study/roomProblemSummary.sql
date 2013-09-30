/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
SELECT
  t.room,
  t.category,
  t.totalIdsInRoom as totalIds,
  t.totalIdWithProblems,
  t.totalProblems,
  round((cast(t.totalIdWithProblems as double) / t.totalIdsInRoom) * 100.0, 2) as pctWithProblem,

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