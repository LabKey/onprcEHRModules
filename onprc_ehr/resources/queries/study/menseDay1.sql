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
  t.date,
  t.observation,
  t.previousMens,
  timestampdiff('SQL_TSI_DAY', t.previousMens, t.date) as daysSinceLastMens

FROM (

SELECT
  o.Id,
  o.dateOnly as date,
  o.observation,
  (SELECT max(CAST(o2.date as date)) as expr FROM study.clinical_observations o2 WHERE o2.Id = o.Id AND o2.category = 'Menses' and o2.date < o.date) as previousMens

FROM study.clinical_observations o
WHERE o.category = 'Menses'

) t

WHERE (timestampdiff('SQL_TSI_DAY', t.previousMens, t.date)) > 14