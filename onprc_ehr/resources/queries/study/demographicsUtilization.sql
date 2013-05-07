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
  cast(a.project.investigatorId.lastName || ' [' || a.project.name || ']' as varchar) as use,
  cast(a.project.use_category as varchar) as category
FROM study.assignment a
WHERE a.enddateCoalesced >= curdate()

UNION ALL

SELECT
  a.Id,
  a.groupId.name,
  a.groupId.category as category

FROM ehr.animal_group_members a
WHERE a.enddateCoalesced >= curdate()

) t

GROUP BY t.Id