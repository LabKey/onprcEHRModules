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
d.id,
CASE
  WHEN (count(a.lsid) > 0 OR count(f.lsid) > 0)
    THEN true
    ELSE false
END as status,
group_concat(DISTINCT a.project.displayName, chr(10)) as projects,
group_concat(DISTINCT f.flag.value) as flags,

FROM study.demographics d
LEFT JOIN study.assignment a ON (a.id = d.id AND (a.releaseCondition.meaning = 'Terminal' OR a.projectedReleaseCondition.meaning = 'Terminal'))
LEFT JOIN study.flags f ON (f.id = d.id AND f.isActive = true AND f.flag.category = 'Condition' AND f.flag.value in ('Clinically Restricted', 'Terminal'))
WHERE d.calculated_status = 'Alive'
GROUP BY d.id