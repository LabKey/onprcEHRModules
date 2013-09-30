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
  t.project,
  t.category,
  t.totalIds,
  t.totalIdWithProblems,
  t.totalProblems,

  t.startDate,
  t.endDate,

  round((cast(t.totalIdWithProblems as double) / t.totalIds) * 100.0, 2) as pctWithProblem,

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