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
  t.groupId,
  t.Id,
  --NOTE: add 0.5 to include kinship with self
  CAST(((0.5 + coalesce(t.sumCoefficient, 0)) / (select count(*) as total from study.animal_group_members d where d.isActive = true and d.groupId = t.groupId)) as double) as avgCoefficient,
  t.distinctAnimals,
  (select count(*) as total from study.animal_group_members d where d.isActive = true and d.groupId = t.groupId) as totalInPopulation

FROM (

SELECT
  d.groupId,
  d.Id,
  sum(k.coefficient) as sumCoefficient,
  count(k.Id2) as distinctAnimals

FROM study.animal_group_members d
JOIN ehr.kinshipSummary k ON (d.Id = k.Id)
JOIN study.animal_group_members d2 ON (d2.Id = k.Id2 and d.groupId = d2.groupId)

WHERE
  d.isActive = true and
  d2.isActive = true

GROUP BY d.groupId, d.Id

) t