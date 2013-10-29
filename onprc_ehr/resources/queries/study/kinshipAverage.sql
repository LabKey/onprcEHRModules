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
  --NOTE: add 0.5 to include kinship with self
  CAST((0.5 + coalesce(t.sumCoefficient, 0)) / (select count(*) as total from study.demographics d where d.calculated_status = 'Alive' and d.species = t.species) as double) as avgCoefficient,
  t.distinctAnimals,
  (select count(*) as total from study.demographics d where d.calculated_status = 'Alive' and d.species = t.species) as totalInPopulation,
  t.species

FROM (

SELECT
  d.Id,
  max(d.species) as species,
  sum(k.coefficient) as sumCoefficient,
  count(k.Id2) as distinctAnimals

FROM study.demographics d
JOIN study.demographics d2 ON (d2.calculated_status = 'Alive' and d.species = d2.species)
LEFT JOIN ehr.kinshipSummary k ON (d.Id = k.Id AND d2.Id = k.Id2)

WHERE d.calculated_status = 'Alive'

GROUP BY d.Id

) t