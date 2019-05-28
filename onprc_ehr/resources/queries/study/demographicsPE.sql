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
d.id.age.AgeInYears,
max(e.date) as lastdate,
TIMESTAMPDIFF('SQL_TSI_DAY', max(e.date), now()) as daysSinceExam,
COALESCE(CASE
  WHEN d.id.age.AgeInYears >= 18.0 THEN (180 - TIMESTAMPDIFF('SQL_TSI_DAY', max(e.date), now()))
  ELSE (365 - TIMESTAMPDIFF('SQL_TSI_DAY', max(e.date), now()))
END, 0) as daysUntilNextExam,
count(e.lsid) as totalExams,
CASE
  WHEN count(f.Id) = 0 THEN null
  ELSE 'Clinically Restricted'
END as isRestricted

FROM study.demographics d
LEFT JOIN (
  select
    e.id,
    e.date,
    e.lsid
  FROM study.encounters e
  left join ehr.snomed_tags t on (e.objectid = t.recordid)
  where (e.procedureid.name IN ('Physical Exam Complete') OR t.code IN ('P-02314', 'P-02310')) and e.id.demographics.calculated_status = 'Alive'
) e ON (e.id = d.id)

--find terminal condition codes
LEFT JOIN (
  SELECT
    f.Id
  FROM study.flags f
  WHERE f.isActive = true AND f.flag.category = 'Condition' AND f.flag.value = 'Clinically Restricted'
  GROUP BY f.Id
) f ON (f.Id = d.Id)

WHERE d.calculated_status = 'Alive'

GROUP BY d.id, d.id.age.AgeInYears