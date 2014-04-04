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
  t.Id,
  t.labworkDate,
  t.PLT,
  t.HCT,
  t.runIdPLT,
  t.runIdHCT,
  CASE
    WHEN (t.HCT < 30 OR t.PLT < 50) THEN 'WARNING'
    ELSE null
  END as status
FROM (
SELECT
  d.Id,
  max(t.lastDate) as labworkDate,
  max(CASE WHEN (hr1.testid = 'PLT') THEN hr1.result ELSE NULL END) as PLT,
  max(CASE WHEN (hr1.testid = 'HCT') THEN hr1.result ELSE NULL END) as HCT,

  max(CASE WHEN (hr1.testid = 'PLT') THEN hr1.runId ELSE NULL END) as runIdPLT,
  max(CASE WHEN (hr1.testid = 'HCT') THEN hr1.runId ELSE NULL END) as runIdHCT,

FROM study.demographics d
LEFT JOIN (
  SELECT r.id, max(r.date) as lastDate
  FROM study.clinpathRuns r
  WHERE r.type = 'Hematology'
  GROUP BY r.id
) t ON (t.id = d.id)
LEFT JOIN study.hematologyResults hr1 ON (hr1.id = d.id AND hr1.date = t.lastDate AND (hr1.testid = 'PLT' OR hr1.testid = 'HCT'))

WHERE d.calculated_status = 'Alive'
GROUP BY d.Id
) t