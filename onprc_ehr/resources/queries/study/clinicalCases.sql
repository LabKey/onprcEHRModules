/*
 * Copyright (c) 2014-2017 LabKey Corporation
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
  c.Id,
  c.date,
  c.enddate,
  c.reviewdate,
  c.category,
  c.performedby,
  c.description,
  c.problemCategories,
  c.remark,
  c.mostRecentP2,
  c.isActive,
  c.assignedvet

FROM study.cases c
WHERE c.isActive = true AND c.category = 'Clinical'

UNION ALL

SELECT
  d.Id,
  d.date,

  null as enddate,
  null as reviewdate,
  null as category,
  null as performedby,
  null as description,
  null as problemCategories,
  null as remark,
  null as mostrecentP2,
  null as isActive,
  null as assignedVet

FROM study.demographicsCurrentLocation d
WHERE d.area = 'Hospital' AND (d.Id.activecases.categories NOT LIKE '%Clinical%' OR d.Id.activecases.categories IS NULL)