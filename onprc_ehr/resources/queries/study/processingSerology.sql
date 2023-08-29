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
--  Modified: 8-30-2023  R. Blasa
SELECT
  t.Id,
  t.ageInDays,
  t.lastSRV,
  t.daysSinceSRV,
  t.isSRVRequired,
  t.isSRVCurrent,
  CASE
    WHEN (t.isSRVRequired = true AND t.isSRVCurrent = false) THEN 4
    ELSE 0
  END as srvBloodVol,

FROM (

SELECT
  d.Id,
  d.Id.age.ageInDays,
  s.lastDate as lastSRV,
  timestampdiff('SQL_TSI_DAY', s.lastDate, now()) as daysSinceSRV,
  CASE
    WHEN (year(now()) = year(s.lastDate)) THEN true
    ELSE false
  END as isSRVCurrent,
  --all Jmacs and all non-SPF cynos
  CASE
    WHEN (d.Id.age.ageInDays > 180 AND (d.species in ( 'CYNOMOLGUS MACAQUE','RHESUS MACAQUE','JAPANESE MACAQUE'))) THEN true
    ELSE false
  END as isSRVRequired

FROM study.demographics d

LEFT JOIN (
  SELECT
    s.id,
    max(s.date) as lastDate

  FROM study.blood s
  WHERE s.additionalservices in ('SPF Surveillance – Annual')
  GROUP BY s.id

) s ON (s.id = d.id)

WHERE d.calculated_status = 'Alive'

) t