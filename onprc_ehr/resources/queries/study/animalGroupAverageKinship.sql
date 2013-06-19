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
  d.groupId,
  d.Id,
  avg(k.coefficient) as avgCoefficient,
  count(k.Id2) as distinctAnimals

FROM ehr.animal_group_members d
JOIN ehr.kinship k ON (d.Id = k.Id)
JOIN ehr.animal_group_members d2 ON (d2.Id = k.Id2 and d.groupId = d2.groupId)

WHERE
  d.enddateCoalesced >= curdate() and
  d2.enddateCoalesced >= curdate() and
  d.date <= now() and
  d2.date <= now()

GROUP BY d.groupId, d.Id
