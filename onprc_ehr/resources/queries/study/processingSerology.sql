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
--  Modified: 5-21-2024 R. Blasa
SELECT
  t.Id,
  t.ageInDays,
  t.spfStatus,
  t.lastSRV,
  t.daysSinceSRV,
  t.isSRVRequired,
  t.isSRVCurrent,
  t.additionalservices,
  CASE
    WHEN (t.isSRVRequired = true AND t.isSRVCurrent = false) THEN 4
    ELSE 0
  END as srvBloodVol,

  CASE
    WHEN (t.isSRVRequired = true AND t.isSRVCurrent = false)  THEN 4
    ELSE 0
  END as bloodVol
FROM (

SELECT
  d.Id,
  d.Id.age.ageInDays,
  spf.spfStatus,
  s.additionalservices,
  srv.lastDate as lastSRV,
  timestampdiff('SQL_TSI_DAY', srv.lastDate, now()) as daysSinceSRV,
  CASE
      WHEN (year(now()) = year(srv.lastDate)) THEN true
    ELSE false
  END as isSRVCurrent,
  --all Jmacs and all non-SPF cynos

  CASE
--     WHEN (d.Id.age.ageInDays > 180 AND (d.species in ( 'CYNOMOLGUS MACAQUE','RHESUS MACAQUE','JAPANESE MACAQUE'))) THEN true
      WHEN (d.Id.age.ageInDays > 180 ) And (spf.Id IS NULL ) THEN true
    ELSE false
  END as isSRVRequired

FROM study.demographics d

LEFT JOIN (
  SELECT
    s.id,
    max(s.date) as lastDate,
    s.additionalservices

  FROM study.blood s
  WHERE s.additionalservices like 'SPF%' or s.additionalservices like  'PCR%'
  GROUP BY s.id


) s ON (s.id = d.id)

LEFT JOIN (
    SELECT
        f.Id,
        group_concat(f.flag.value) as spfStatus
    FROM study.flags f
    WHERE f.isActive = true AND f.flag.category = 'SPF'
    GROUP BY f.Id
) spf ON (spf.Id = d.Id)

WHERE d.calculated_status = 'Alive'

) t