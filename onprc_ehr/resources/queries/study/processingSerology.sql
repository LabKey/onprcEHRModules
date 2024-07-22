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
  t.lastSRV,
  t.daysSinceSRV,
  t.isSRVRequired,
  t.isSRVCurrent,
  t.lastPCR,
  t.daysSincePCR,
  t.isPCRRequired,
  t.isPCRCurrent,

  CASE
    WHEN (t.isSRVRequired = true AND t.isSRVCurrent = false) THEN 4
    ELSE 0
  END as srvBloodVol,

  CASE
    WHEN  (t.isPCRRequired = true AND t.isPCRCurrent = false)  THEN 4
    ELSE 0
  END as PCRbloodVol,


FROM (

SELECT
  d.Id,
  d.Id.age.ageInDays,
  srv.lastDate as lastSRV,
  timestampdiff('SQL_TSI_DAY', srv.lastDate, now()) as daysSinceSRV,
  CASE
  WHEN (year(now()) = year(srv.lastDate)) THEN true
    ELSE false
  END as isSRVCurrent,

  CASE
   WHEN (d.Id.age.ageInDays > 180 )THEN true
    ELSE false
  END as isSRVRequired,

    pcr.lastDate as lastPCR,
    timestampdiff('SQL_TSI_DAY', pcr.lastDate, now()) as daysSincePCR,
    CASE
     WHEN (year(now()) = year(pcr.lastDate)) THEN true
    ELSE false
     END as isPCRCurrent,

  CASE
   WHEN (d.Id.age.ageInDays > 180 )  THEN true
    ELSE false
    END as isPCRRequired

FROM study.demographics d

LEFT JOIN (
  SELECT
    s.id,
    max(s.date) as lastDate
  FROM study.blood s
  WHERE (s.additionalservices like 'SPF Surveillance%' or s.additionalservices like  'Compromised SPF%')
  GROUP BY s.id

) srv ON (srv.id = d.id)

LEFT JOIN (
    SELECT
        b.id,
        max(b.date) as lastDate
    FROM study.blood b
    WHERE b.additionalservices like  'PCR%'
    GROUP BY b.id

) pcr ON (pcr.id = d.id)


WHERE d.calculated_status = 'Alive'

) t