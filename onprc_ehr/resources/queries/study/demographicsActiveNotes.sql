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
  f1.Id,
  group_concat(f1.flag, chr(10)) as notes

FROM (
SELECT
  f.Id,
  CASE
    WHEN f.value is null THEN null
    WHEN f.category IS NULL THEN f.value
    ELSE cast((CAST(f.category as varchar(100)) || CAST(': ' as varchar(2)) || CAST(f.value as varchar(3800))) as varchar(4000))
  END as flag

FROM study.notes f
WHERE f.isActive = true

) f1

GROUP BY f1.Id