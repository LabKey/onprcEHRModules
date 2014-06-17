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
  t.date,
  t.observation,
  1 + TIMESTAMPDIFF('SQL_TSI_DAY', t.cycleStart, t.date) as cycleDay,
  t.cycleStart,
  CASE
    WHEN (t.cycleStart = t.date) THEN 'Y'
    ELSE null
  END as isDay1,
  t.remark,
  t.performedby,
  t.taskid

FROM (

SELECT
  o.Id,
  CAST(o.dateOnly AS TIMESTAMP) as date,
  o.observation,
  (SELECT max(md.date) as expr FROM study.menseDay1 md WHERE md.Id = o.Id AND md.date <= o.dateOnly) as cycleStart,
  o.remark,
  o.performedby,
  o.taskid

FROM study.clinical_observations o

WHERE o.category = 'Menses'

) t