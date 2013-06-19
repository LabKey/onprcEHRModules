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
  d.Id,
  avg(coalesce(k.coefficient, 0)) as avgCoefficient,
  count(k.Id2) as distinctRelatedAnimals,
  count(d2.Id) as distinctAnimals

FROM study.demographics d
JOIN study.demographics d2 ON (d.calculated_status = 'Alive' AND d2.calculated_status = 'Alive')

LEFT JOIN ehr.kinship k ON (d.Id = k.Id AND d2.Id = k.Id2)

GROUP BY d.Id
