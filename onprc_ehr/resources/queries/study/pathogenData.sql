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
PARAMETERS(StartDate TIMESTAMP, EndDate TIMESTAMP)

SELECT
  r.*,
  f1.viralStatus as viralStatus,
  f2.viralStatus as viralStatusAtEnd,
  CASE
    WHEN (f1.viralStatus IS NULL AND f2.viralStatus IS NULL) THEN 'Never SPF'
    WHEN (d.death IS NOT NULL) THEN 'Dead'
    WHEN (dp.date IS NOT NULL) THEN 'Shipped'
    WHEN (f1.viralStatus IS NOT NULL AND f2.viralStatus IS NULL) THEN 'Dropped From SPF'
    WHEN (f1.viralStatus IS NOT NULL AND f2.viralStatus IS NOT NULL) THEN 'SPF'
    ELSE '?'
  END as SPFStatus,
  CASE
    WHEN f1.viralStatus IS NULL THEN 0
    ELSE 1
  END as wasSPF,
  CASE
    WHEN f2.viralStatus IS NULL THEN 0
    ELSE 1
  END as endedSPF,
  CASE
    WHEN (d.id IS NOT NULL OR dp.id IS NOT NULL) THEN null
    WHEN (f1.viralStatus IS NOT NULL AND f2.viralStatus IS NULL) THEN r.id
    ELSE null
  END as droppedFromSPFId,
  CASE
    WHEN (d.id IS NOT NULL OR dp.id IS NOT NULL) THEN 1
    ELSE 0
  END as leftCenter,
  CASE
    WHEN (d.id IS NOT NULL OR dp.id IS NOT NULL) THEN r.id
    ELSE null
  END as leftCenterId,
  CASE
    WHEN f1.viralStatus IS NULL THEN null
    ELSE r.id
  END as wasSPFId,
  CASE
    WHEN f2.viralStatus IS NULL THEN null
    ELSE r.id
  END as endedSPFId,
  CASE
    WHEN f1.viralStatus IS NULL THEN r.Id
    ELSE null
  END as neverSPFId,
FROM (

SELECT
  'Serology' as category,
  t.Id,
  t.date,
  t.agent.meaning as pathogen,
  t.result,
  null as qualifier,
  --t.qualifier,
  t.housingAtTime.roomAtTime,
  StartDate,
  EndDate,
  CASE
    WHEN (t.result like 'Pos%') THEN 1
    ELSE 0
  END as positive,
  CASE
    WHEN (t.result like 'Pos%') THEN 0
    ELSE 1
  END as negative,
  CASE
    WHEN (t.result like 'Pos%') THEN t.id
    ELSE null
  END as IdPositive,
  CASE
    WHEN (t.result like 'Pos%') THEN null
    ELSE t.Id
  END as IdNegative,
  t2.totalTests,
  t2.totalIds,
  t.history,

FROM study.serology t
LEFT JOIN (
  SELECT
    agent,
    count(t2.lsid) as totalTests,
    count(distinct t2.Id) as totalIds
  FROM study."Serology Results" t2
  WHERE t2.date >= StartDate AND t2.date <= EndDate AND (t2.result LIKE 'Pos%' OR t2.result LIKE 'Neg%')
  GROUP BY t2.agent
) t2 ON (t.agent = t2.agent)
WHERE t.date >= StartDate AND t.date <= EndDate
AND (t.result LIKE 'Pos%' OR t.result LIKE 'Neg%')

UNION ALL

SELECT
  'Parasitology' as category,
  t.Id,
  t.date,
  t.organism.meaning as pathogen,
  null as result,
  t.qualresult,
  t.housingAtTime.roomAtTime,
  StartDate,
  EndDate,
  CASE
    WHEN (t.organism.meaning != 'ETIOLOGIC AGENT NOT IDENTIFIED,(NEGATIVE)') THEN 1
    ELSE 0
  END as positive,
  CASE
    WHEN (t.organism.meaning != 'ETIOLOGIC AGENT NOT IDENTIFIED,(NEGATIVE)') THEN 0
    ELSE 1
  END as negative,
  CASE
    WHEN (t.organism.meaning != 'ETIOLOGIC AGENT NOT IDENTIFIED,(NEGATIVE)') THEN t.id
    ELSE null
  END as IdPositive,
  CASE
    WHEN (t.organism.meaning != 'ETIOLOGIC AGENT NOT IDENTIFIED,(NEGATIVE)') THEN null
    ELSE t.id
  END as IdNegative,
  (select count(t2.lsid) as total FROM study.parasitologyResults t2 WHERE t2.date >= StartDate AND t2.date <= EndDate) as totalTests,
  (select count(distinct t2.Id) as total FROM study.parasitologyResults t2 WHERE t2.date >= StartDate AND t2.date <= EndDate) as totalIds,
  t.history,

FROM study.parasitologyResults t
WHERE t.date >= StartDate AND t.date <= EndDate
AND t.organism.meaning != 'ETIOLOGIC AGENT NOT IDENTIFIED,(NEGATIVE)'

UNION ALL

SELECT
  'Bacteriology' as category,
  t.Id,
  t.date,
  t.organism.meaning as pathogen,
  quantity as result,
  null as qualResult,
  t.housingAtTime.roomAtTime,
  StartDate,
  EndDate,
  CASE
    WHEN (t.organism.meaning != 'ETIOLOGIC AGENT NOT IDENTIFIED,(NEGATIVE)') THEN 1
    ELSE 0
  END as positive,
  CASE
    WHEN (t.organism.meaning != 'ETIOLOGIC AGENT NOT IDENTIFIED,(NEGATIVE)') THEN 0
    ELSE 1
  END as negative,
  CASE
    WHEN (t.organism.meaning != 'ETIOLOGIC AGENT NOT IDENTIFIED,(NEGATIVE)') THEN t.id
    ELSE null
  END as IdPositive,
  CASE
    WHEN (t.organism.meaning != 'ETIOLOGIC AGENT NOT IDENTIFIED,(NEGATIVE)') THEN null
    ELSE t.id
  END as IdNegative,
  (select count(t2.lsid) as total FROM study.microbiology t2 WHERE t2.date >= StartDate AND t2.date <= EndDate) as totalTests,
  (select count(distinct t2.Id) as total FROM study.microbiology t2 WHERE t2.date >= StartDate AND t2.date <= EndDate) as totalIds,
  t.history,

FROM study.microbiology t
WHERE t.date >= StartDate AND t.date <= EndDate
AND t.organism.meaning != 'ETIOLOGIC AGENT NOT IDENTIFIED,(NEGATIVE)'

) r

LEFT JOIN (
  SELECT
    f1.id,
    group_concat(DISTINCT f1.flag.value) as viralStatus
  FROM study.flags f1 WHERE
    f1.flag.value like 'SPF%' AND
    f1.date <= EndDate AND
    f1.enddateCoalesced >= StartDate
  GROUP BY f1.id
) f1 ON (f1.id = r.id)

LEFT JOIN (
  SELECT
    f2.id,
    group_concat(DISTINCT f2.flag.value) as viralStatus,
  FROM study.flags f2 WHERE
    f2.flag.value like 'SPF%' AND
    f2.date <= EndDate AND
    f2.enddateCoalesced >= EndDate
  GROUP BY f2.id
) f2 ON (f2.id = r.id)

LEFT JOIN study.demographics d ON (d.id = r.id AND d.death >= StartDate AND d.death <= EndDate)

LEFT JOIN study.departure dp ON (dp.id = r.id AND dp.date >= StartDate AND dp.date <= EndDate)