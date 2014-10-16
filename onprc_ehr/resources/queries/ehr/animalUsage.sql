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
  p.protocol,
  pc.project,
  pc.species,
  coalesce(pc.gender.meaning, 'Male/Female') as gender,
  pc.start,
  pc.enddate,
  pc.description,
  pc2.totalAssignments,
  pc.allowed,
  pc2.totalAnimals,
  pc2.excludedAnimals,
  pc2.animals,
  CASE
    WHEN pc.allowed > 0 THEN (pc.allowed - pc2.totalAnimals)
    ELSE null
  END as totalRemaining,
  cast(CASE
    WHEN pc.allowed > 0 THEN ((pc2.totalAnimals / CAST(pc.allowed as double)) * 100)
    ELSE null
  END as double) as pctUsed,
  CASE
    WHEN (pc.start IS NULL and p.enddateTimeCoalesced >= now()) THEN true
    WHEN (pc.start <= now() AND pc.enddateTimeCoalesced >= now()) THEN true
    ELSE false
  END as isActive,
  p.container

FROM ehr.protocol p
LEFT JOIN ehr.protocol_counts pc ON (p.protocol = pc.protocol OR pc.project.protocol = p.protocol)
LEFT JOIN (
  SELECT
    pc.rowid,
    count(a.lsid) as totalAssignments,
    count(DISTINCT CASE WHEN (a.releaseType IS NULL OR a.releaseType NOT LIKE '%IACUC Excluded%') THEN a.Id ELSE null END) as totalAnimals,
    count(DISTINCT CASE WHEN (a.releaseType IS NULL OR a.releaseType NOT LIKE '%IACUC Excluded%') THEN null ELSE a.Id END) as excludedAnimals,
    group_concat(DISTINCT CASE WHEN (a.releaseType IS NULL OR a.releaseType NOT LIKE '%IACUC Excluded%') THEN a.Id ELSE null END) as animals
  FROM ehr.protocol_counts pc
  JOIN study.assignment a ON (
    (a.dateOnly < pc.enddateCoalesced AND a.enddateCoalesced >= pc.start) AND
    (pc.protocol IS NULL OR pc.protocol = a.project.protocol) AND
    (pc.project IS NULL OR pc.project = a.project) AND
    ((pc.species IS NULL OR pc.species = a.Id.demographics.species) OR pc.species = 'UNIDENTIFIED MACAQUE' AND a.Id.demographics.species LIKE '%MACAQUE%') AND
    (pc.gender IS NULL OR pc.gender = a.Id.demographics.gender)
  )
  GROUP BY pc.rowid
) pc2 ON (pc.rowid = pc2.rowid)