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
  t.Id,
  t.ageInDays,
  t.spfStatus,
  t.lastHBV,
  t.daysSinceHBV,
  t.isHBVRequired,
  t.isHBVCurrent,
  CASE
    WHEN (t.isHBVRequired = true AND t.isHBVCurrent = false) THEN 4
    ELSE 0
  END as hbvBloodVol,

  t.lastSRV,
  t.daysSinceSRV,
  t.isSRVRequired,
  t.isSRVCurrent,
  CASE
    WHEN (t.isSRVRequired = true AND t.isSRVCurrent = false) THEN 4
    ELSE 0
  END as srvBloodVol,

  CASE
    WHEN ((t.isSRVRequired = true AND t.isSRVCurrent = false) OR (t.isHBVRequired = true AND t.isHBVCurrent = false)) THEN 4
    ELSE 0
  END as bloodVol
FROM (

SELECT
  d.Id,
  d.Id.age.ageInDays,
  spf.spfStatus,
  s.lastDate as lastHBV,
  timestampdiff('SQL_TSI_DAY', s.lastDate, now()) as daysSinceHBV,
  --all SPF animals over 180 days
  CASE
    WHEN (spf.Id IS NOT NULL AND d.Id.age.ageInDays > 180) THEN true
    ELSE false
  END as isHBVRequired,
  CASE
    WHEN (year(now()) = year(s.lastDate)) THEN true
    ELSE false
  END as isHBVCurrent,

  srv.lastDate as lastSRV,
  timestampdiff('SQL_TSI_DAY', srv.lastDate, now()) as daysSinceSRV,
  CASE
    WHEN (year(now()) = year(srv.lastDate)) THEN true
    ELSE false
  END as isSRVCurrent,
  --all Jmacs and all non-SPF cynos
  CASE
    WHEN (d.Id.age.ageInDays > 180 AND ((spf.Id IS NULL AND d.species = 'CYNOMOLGUS MACAQUE') OR d.species = 'JAPANESE MACAQUE')) THEN true
    ELSE false
  END as isSRVRequired,

FROM study.demographics d

LEFT JOIN (
  SELECT
    s.id,
    max(s.date) as lastDate

  FROM study.serology s
  WHERE s.agent.meaning like '% HBV%' or s.agent.meaning like '%Herpes%'
  GROUP BY s.id

) s ON (s.id = d.id)

LEFT JOIN (
  SELECT
    s.id,
    max(s.date) as lastDate

  FROM study.serology s
  WHERE s.agent.meaning like '%SRV%'
  GROUP BY s.id

) srv ON (srv.id = d.id)

LEFT JOIN (
  SELECT
    f.Id,
    group_concat(f.flag.value) as spfStatus,
  FROM study.flags f
  WHERE f.isActive = true AND f.flag.category = 'SPF'
  GROUP BY f.Id
) spf ON (spf.Id = d.Id)

WHERE d.calculated_status = 'Alive'

) t