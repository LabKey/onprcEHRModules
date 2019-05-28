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
--NOTE: this query has been modified to be based on demographics for perf reasons
SELECT
  d.id,
  t.room,
  t.effectiveCage,
  t.total,
  cast(t.animals as varchar(4000)) as animals,
  CASE
    WHEN t.housingType != 'Cage Location' THEN 'Group'
    WHEN (t.total > 1 AND t.countAsSeparate = true AND t.countAsPaired = true) THEN 'Cage, Grooming'
    WHEN t.total = 1 THEN 'Cage, Single'
    WHEN t.total > 1 THEN 'Cage, Paired'
    ELSE 'Unknown'
  END as category,
  t.housingType,
  t.countAsSeparate,
  t.countAsPaired,

FROM study.demographics d
LEFT JOIN (
SELECT
  h.id,
  h.room,
  h.room.housingType.value as housingType,
  h.effectiveCage.effectiveCage,
  c.divider.countAsPaired as countAsPaired,
  c.divider.countAsSeparate as countAsSeparate,

  count(distinct h2.id) as total,
  group_concat(distinct h2.id, ', ') as animals,

FROM study.housing h

--NOTE: this filter is added because otherwise a monkey marked as dead (but still with a housing record) could be
JOIN study.housing h2
ON (h2.Id.demographics.calculated_status = 'Alive' AND h.room = h2.room and (h.effectiveCage.effectiveCage = h2.effectiveCage.effectiveCage OR (h.cage IS NULL and h2.cage IS NULL) OR (h.room.housingType.value != 'Cage Location' AND h.cage = h2.cage)))

LEFT JOIN ehr_lookups.cage c ON (h.effectiveCage.effectiveCage = c.cage AND c.room = h.room)

--account for date/time
WHERE h.enddateTimeCoalesced >= now() and h2.enddateTimeCoalesced >= now()
    --TODO: qc

GROUP BY h.id, h.room, h.effectiveCage.effectiveCage, c.divider.countAsPaired, c.divider.countAsSeparate, h.room.housingType.value

) t ON (t.id = d.id)

WHERE d.calculated_status = 'Alive'