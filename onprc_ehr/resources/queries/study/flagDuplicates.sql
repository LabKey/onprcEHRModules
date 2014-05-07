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
  f.id,
  f.flag.category as category,
  group_concat(f.flag.value, chr(10)) as values,
  count(f.flag.value) as totalFlags

FROM study.flags f
JOIN ehr_lookups.flag_categories fc ON (f.flag.category = fc.category)
WHERE fc.enforceUnique = true and f.isActive = true
GROUP BY f.id, f.flag.category
HAVING count(*) > 1
