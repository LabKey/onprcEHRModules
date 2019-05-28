/*
 * Copyright (c) 2013-2014 LabKey Corporation
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
  t.groupCategory,
  t.category,
  t.totalIdsInCategory as totalIds,
  t.totalIdWithProblems,
  t.totalProblems,
  round((cast(t.totalIdWithProblems as float) / t.totalIdsInCategory * 100.0), 2) as pctWithProblem,
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
  (select count(distinct m.id) FROM study.animal_group_members m WHERE (m.date <= max(t1.EndDate) AND m.enddateCoalesced >= max(t1.StartDate) AND m.groupId.category = g.category)) as totalIdsInCategory

FROM study.animalGroupProblemData t1
JOIN ehr.animal_groups g ON (t1.groupId = g.rowid)
GROUP BY g.category, t1.category

) t