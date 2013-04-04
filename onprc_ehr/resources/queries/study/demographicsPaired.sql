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
--NOTE: this query has been modified to be based on demographics for perf reasons
SELECT
  d.id,
  t.room,
  t.effectiveCage,
  t.total,
  t.animals

FROM study.demographics d
LEFT JOIN (
SELECT
  h.id,
  h.room,
  h.effectiveCage.effectiveCage,

  count(distinct h2.id) as total,
  group_concat(distinct h2.id, ', ') as animals,

FROM study.housing h

JOIN study.housing h2
ON (h.room = h2.room and (h.effectiveCage.effectiveCage = h2.effectiveCage.effectiveCage OR (h.cage IS NULL and h2.cage IS NULL)))

--account for date/time
WHERE h.enddateTimeCoalesced >= now() and h2.enddateTimeCoalesced >= now()

GROUP BY h.id, h.room, h.effectiveCage.effectiveCage

) t ON (t.id = d.id)

WHERE d.calculated_status = 'Alive'