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
  s.Id,
  min(s.date) as minDate,
  max(s.date) as maxDate,
  max(estDeliveryDate) as estDeliveryDate,
  count(s.Id) as totalCodes,
  group_concat(s.text, chr(10)) as codes

FROM (

SELECT
  s.Id,
  s.date,
  null as estDeliveryDate,
  (cast(year(s.date) as varchar) || '-' || CASE WHEN month(s.date) < 10 THEN '0' ELSE '' END || cast(month(s.date) as varchar) || '-' || CASE WHEN dayofmonth(s.date) < 10 THEN '0' ELSE '' END || cast(dayofmonth(s.date) as varchar) || ': ' || s.code.meaning) as text

FROM ehr.snomed_tags s
WHERE s.code IN ('F-31040', 'F-31030', 'F-31020') AND timestampdiff('SQL_TSI_DAY', s.date, curdate()) < 150

UNION ALL

SELECT
  p.id,
  p.date,
  p.estDeliveryDate,
  (cast(year(p.date) as varchar) || '-' || CASE WHEN month(p.date) < 10 THEN '0' ELSE '' END || cast(month(p.date) as varchar) || '-' || CASE WHEN dayofmonth(p.date) < 10 THEN '0' ELSE '' END || cast(dayofmonth(p.date) as varchar) || ': ' || p.confirmationType) as text

FROM study.pregnancyOutcome p
WHERE p.birthDate IS NULL AND timestampdiff('SQL_TSI_DAY', p.date, curdate()) < 150

) s

GROUP BY s.Id