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
  a.Id,
  a.project,
  a.project.protocol,
  a.date,
  a.enddate

FROM study.assignment a
LEFT JOIN ehr.protocol_counts pc ON (
  (a.dateOnly < pc.enddateCoalesced AND a.enddateCoalesced >= pc.start) AND
  (pc.protocol IS NULL OR pc.protocol = a.project.protocol) AND
  (pc.project IS NULL OR pc.project = a.project) AND
  ((pc.species IS NULL OR pc.species = a.Id.demographics.species) OR pc.species = 'UNIDENTIFIED MACAQUE' AND a.Id.demographics.species LIKE '%MACAQUE%') AND
  (pc.gender IS NULL OR pc.gender = a.Id.demographics.gender)
)

WHERE pc.rowid IS NULL