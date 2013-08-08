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
  t1.Id,
  group_concat(t1.category, chr(10)) as categories
FROM (
SELECT
  t.Id,
  cast((t.category || cast(' (' as varchar) || cast(t.total as varchar) || cast(')' as varchar)) as varchar(500)) as category

FROM (
SELECT
  p.Id,
  p.category,
  count(*) as total
FROM study."Problem List" p
WHERE p.daysElapsed <= 730
GROUP BY p.Id, p.category

) t

) t1
GROUP BY t1.id
