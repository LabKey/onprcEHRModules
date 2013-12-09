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
  t.Id,
  group_concat(DISTINCT t.use, chr(10)) as use,
  group_concat(DISTINCT t.category, chr(10)) as usageCategories

FROM (

SELECT
  a.Id,
  cast(CASE
    WHEN a.project.investigatorId IS NOT NULL THEN (a.project.investigatorId.lastName || ' [' || a.project.name || ']')
    ELSE a.project.name
  END as varchar(500)) as use,
  cast(a.project.use_category as varchar(500)) as category
FROM study.assignment a
WHERE a.isActive = true

UNION ALL

SELECT
  a.Id,
  a.groupId.name,
  a.groupId.category as category

FROM ehr.animal_group_members a
WHERE a.isActive = true

UNION ALL

SELECT
f.Id,
f.value as name,
null as category

FROM study.flags f
WHERE f.isActive = true AND f.category = 'Assign Alias'

) t

GROUP BY t.Id