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
  t.lastDate as labworkDate,
  hr1.result as PLT,
  hr2.result as HCT,
  hr1.runId as runIdPLT,
  hr2.runId as runIdHCT,
  CASE
    WHEN (hr2.result < 30 OR hr1.result < 50) THEN 'WARNING'
    ELSE null
  END as status,

FROM study.demographics d
LEFT JOIN (
  SELECT r.id, max(r.date) as lastDate
  FROM study.clinpathRuns r
  WHERE r.type = 'Hematology'
  GROUP BY r.id
) t ON (t.id = d.id)
LEFT JOIN study.hematologyResults hr1 ON (hr1.id = d.id AND hr1.date = t.lastDate AND hr1.testid = 'PLT')
LEFT JOIN study.hematologyResults hr2 ON (hr2.id = d.id AND hr2.date = t.lastDate AND hr2.testid = 'HCT')

WHERE d.calculated_status = 'Alive'
