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
  s.Id,
  min(s.date) as minDate,
  max(s.date) as maxDate,

  count(s.Id) as totalCodes,
  group_concat(s.text) as codes

FROM (

SELECT
  s.Id,
  s.date,
  s.code,
  s.code.meaning as meaning,
  (s.code.meaning || ' (' || cast(dayofmonth(s.date) as varchar) || '-' || cast(month(s.date) as varchar) || '-' || cast(year(s.date) as varchar) || ')') as text

FROM study.encountersWithSnomed s

WHERE s.code IN ('F-31040', 'F-31030', 'F-31020') AND timestampdiff('SQL_TSI_DAY', s.date, curdate()) < 150

) s

GROUP BY s.Id