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
select

a.id,
a.date,
a.runId,
cast(a.runid.tissue as varchar(300)) as tissue,
a.microbe.meaning as microbe,
a.antibiotic.meaning as antibiotic,
GROUP_CONCAT(DISTINCT a.result) as results

from study."Antibiotic Sensitivity" a
WHERE a.antibiotic.code IN (
  'E-71875',
  'E-719Y1',
  'E-719Y3',
  'E-72040',
  'E-72045',
  'E-721X0',
  'E-72360',
  'E-72500',
  'E-72600',
  'E-72682',
  'E-72720',
  'E-Y7240'
)
group by a.id, a.date, a.runId, a.runid.tissue, a.microbe.meaning, a.antibiotic.meaning

pivot results by antibiotic

--the codes correspond to:
-- Trimethoprim/sulfa (480mg)
-- ENROFLOXACIN (68mg)
-- CIPROFLOXACIN (200mg)
-- CHLORAMPHENICOL injectable (250mg/ml)
-- Florfenical injectable (300mg/ml)
-- CEFAZOLIN injectable (250mg/ml)
-- Gentamycin injectable (100mg/ml)
-- Tetracycline (250mg)
-- Penicillin G Procaine injectable (300,000 IU/ml)
-- AMOXICILLIN / CLAVULANIC ACID (250mg)
-- AMPICILLIN (250mg/ml)
-- AZITHROMYCIN (250mg)
