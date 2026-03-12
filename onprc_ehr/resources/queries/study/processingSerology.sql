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

  CASE
      WHEN  (t.isESPFRequired = true AND t.isESPFCurrent = false AND )  THEN 4
      ELSE 0
      END as ESPFbloodVol,

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

    espf.lastDate as lastESPF,
    timestampdiff('SQL_TSI_DAY', espf.lastDate, now()) as daysSinceESPF,
   CASE
      WHEN (year(now()) = year(espf.lastDate) AND daysSinceESPF > 180) THEN true
      ELSE false
      END as isESPFCurrent,

   CASE
      WHEN (d.Id.age.ageInDays > 180 )  THEN true
      ELSE false
      END as isESPFRequired


    ------ All CBC Sections

    cbc.lastDate as lastCBC1,
    timestampdiff('SQL_TSI_DAY', cbc.lastDate, now()) as daysSinceCBC1,
   CASE
      WHEN (year(now()) = year(cbc.lastDate) AND daysSinceCBC1 > 165 AND d.Id.curLocation.area in ('Corrals', 'Shelters', 'PENS' ) ) THEN true
      ELSE false
      END as isCBCCurrent1,

  CASE
      WHEN (d.Id.age.ageInDays > 20 )  THEN true
      ELSE false
      END as isCBCRequired1

    cbc.lastDate as lastCBC2,
    timestampdiff('SQL_TSI_DAY', cbc.lastDate, now()) as daysSinceCBC2,
   CASE
      WHEN (year(now()) = year(cbc.lastDate) AND daysSinceCBC2 > 340 AND d.Id.curLocation.area in ('Corrals', 'Shelters', 'PENS' ) AND (flg.Id is not null) ) THEN true
      ELSE false
      END as isCBCCurrent2,

   CASE
      WHEN (d.Id.age.ageInDays > 180 )  THEN true
      ELSE false
      END as isCBCRequired2

    cbc.lastDate as lastCBC3,
    timestampdiff('SQL_TSI_DAY', cbc.lastDate, now()) as daysSinceCBC3,
   CASE
      WHEN (year(now()) = year(cbc.lastDate) AND daysSinceCBC3 > 340 AND d.Id.curLocation.area in ('Corrals', 'Shelters', 'PENS' )  ) THEN true
      ELSE false
      END as isCBCCurrent3,

   CASE
      WHEN (d.Id.age.ageInDays > 12 )  THEN true
      ELSE false
      END as isCBCRequired3


    cbc.lastDate as lastCBC4,
    timestampdiff('SQL_TSI_DAY', cbc.lastDate, now()) as daysSinceCBC4,
   CASE
      WHEN (year(cbc.lastDate) is null AND d.Id.curLocation.area in ('Corrals', 'Shelters', 'PENS' )  ) THEN true
      ELSE false
      END as isCBCCurrent4,

   CASE
      WHEN (d.Id.age.ageInDays > 6 )  THEN true
      ELSE false
      END as isCBCRequired4


    cbc.lastDate as lastCBC5,,
    timestampdiff('SQL_TSI_DAY', cbc.lastDate, now()) as daysSinceCBC5,
   CASE
      WHEN (year(now()) = year(cbc.lastDate) AND daysSinceCBC5 > 180  AND (nts.Id is not null) )  THEN true
      ELSE false
      END as isCBCCurrent5,

   CASE
      WHEN (d.Id.age.ageInDays > 180 )  THEN true
      ELSE false
      END as isCBCRequired5



      ----- All Comp Chemistry sections


    cchem.lastDate as lastCChem1,
    timestampdiff('SQL_TSI_DAY', cchem.lastDate, now()) as daysSinceCChem1,
  CASE
      WHEN ( ( (year(now()) = year(cchem.lastDate) AND daysSinceCChem1 > 165) OR cchem.lastDate is null )   AND d.Id.curLocation.area in ('Corrals', 'Shelters', 'PENS' )  ) THEN true
      ELSE false
      END as isCChemCurrent1,

  CASE
      WHEN (d.Id.age.ageInDays > 20 )  THEN true
      ELSE false
      END as isCChemRequired1


    cchem.lastDate as lastCChem2,
        timestampdiff('SQL_TSI_DAY', cchem.lastDate, now()) as daysSinceCChem2,
  CASE
      WHEN ( ( (year(now()) = year(cchem.lastDate) AND daysSinceCChem2 > 340) OR cchem.lastDate is null )   AND d.Id.curLocation.area in ('Corrals', 'Shelters', 'PENS' ) AND (flg.Id is not null) ) THEN true
      ELSE false
      END as isCChemCurrent2,

  CASE
      WHEN (d.Id.age.ageInDays > 180 )  THEN true
      ELSE false
      END as isCChemRequired2

    cchem.lastDate as lastCChem3,
        timestampdiff('SQL_TSI_DAY', cchem.lastDate, now()) as daysSinceCChem3,
  CASE
      WHEN ( year(now()) = year(cchem.lastDate) AND daysSinceCChem3 > 180  AND d.Id.curLocation.area in ('Corrals', 'Shelters', 'PENS' )  ) THEN true
      ELSE false
      END as isCChemCurrent3,

  CASE
      WHEN (d.Id.age.ageInDays >= 18 )  THEN true
      ELSE false
      END as isCChemRequired3






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
        k.id,
        max(k.date) as lastDate
    FROM study.blood k
    WHERE (k.additionalservices = 'ESPF Surveillance - Semiannual')
    GROUP BY k.id

) espf ON (espf.id = d.id)

LEFT JOIN (
    SELECT
        b.id,
        max(b.date) as lastDate
    FROM study.blood b
    WHERE b.additionalservices like  'PCR%'
    GROUP BY b.id

) pcr ON (pcr.id = d.id)

LEFT JOIN (
    SELECT
        j.id,
        max(j.date) as lastDate
    FROM study.blood j
    WHERE j.additionalservices like  'CBC with automated differential'
    GROUP BY j.id

) cbc ON (cbc.id = d.id)

LEFT JOIN (
    SELECT
        m.id,
        max(m.date) as lastDate
    FROM study.blood m
    WHERE m.additionalservices like  'Comprehensive Chemistry panel in-house'
    GROUP BY m.id

) cchem ON (cchem.id = d.id)


LEFT JOIN (
    SELECT
        t.id,
        max(t.date) as lastDate
    FROM study.blood t
    WHERE t.additionalservices like  'Basic Chemistry Panel'
    GROUP BY t.id

) bchem ON (bchem.id = d.id)

LEFT JOIN (
    SELECT
        n.id,
        max(n.date) as lastDate
    FROM study.flags n
    WHERE n.category ='Behavior Flag' And n.value = 'Socially important'
    And n.enddate is null
    GROUP BY n.id

) flg ON (flg.id = d.id)


LEFT JOIN (
    SELECT
        p.id,
        max(p.date) as lastDate
    FROM study.flags p
    WHERE p.category ='Notes Pertaining to DAR' And n.value = 'Assignment pool'
      And p.enddate is null
    GROUP BY p.id

) nts ON (nts.id = d.id)


WHERE d.calculated_status = 'Alive'

) t