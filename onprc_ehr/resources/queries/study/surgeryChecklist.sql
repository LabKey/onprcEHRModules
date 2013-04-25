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
  d.id,
  d.species,
  d.gender,
  d.id.activeAssignments.projects,
  d.id.activeAssignments.investigators,
  d.id.age.ageInYears,
  h.result as PLT,
  h2.result as HCT,
FROM study.demographics d
LEFT JOIN (
  SELECT hr.id, hr.result
  FROM study.hematologyResults hr
  WHERE hr.testId = 'PLT' and hr.result IS NOT NULL and hr.date = (SELECT max(date) FROM study.hematologyResults hr2 WHERE hr2.id = hr.id)
) h ON (d.id = h.id)

LEFT JOIN (
  SELECT hr.id, hr.result
  FROM study.hematologyResults hr
  WHERE hr.testId = 'HCT' and hr.result IS NOT NULL and hr.date = (SELECT max(date) FROM study.hematologyResults hr2 WHERE hr2.id = hr.id)
) h2 ON (d.id = h2.id)