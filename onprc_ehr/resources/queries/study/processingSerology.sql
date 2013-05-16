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
  t.ageInDays,
  t.lastDate,
  t.daysSinceHBV,
  t.isHBVCurrent,
  CASE
    WHEN (t.ageInDays > 180 AND t.isHBVCurrent = false) THEN 4
    ELSE 0
  END as bloodVol

FROM (

SELECT
  d.Id,
  d.Id.age.ageInDays,
  s.lastDate,
  timestampdiff('SQL_TSI_DAY', s.lastDate, now()) as daysSinceHBV,
  CASE
    WHEN (year(now()) = year(s.lastDate)) THEN true
    ELSE false
  END as isHBVCurrent,

FROM study.demographics d

LEFT JOIN (
  SELECT
    s.id,
    max(s.date) as lastDate

  FROM study.serology s
  WHERE s.agent.meaning like '% HBV%' or s.agent.meaning like '%Herpes%'
  GROUP BY s.id

) s ON (s.id = d.id)

WHERE d.calculated_status = 'Alive'

) t