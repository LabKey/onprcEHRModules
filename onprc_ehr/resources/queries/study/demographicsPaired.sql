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
  h.id,
  h.room,
  pc.effectiveCage,

  count(distinct h2.id) as total,
  group_concat(distinct h2.id, ', ') as animals,

FROM study.housing h
LEFT JOIN ehr_lookups.pairedCages pc ON (h.room = pc.room and h.cage = pc.cage)

LEFT JOIN (
  SELECT h2.id, h2.room, pc2.effectiveCage, h2.cage, h2.enddateTimeCoalesced
  FROM study.housing h2
  LEFT JOIN ehr_lookups.pairedCages pc2 ON (h2.room = pc2.room and h2.cage = pc2.cage)
) h2 ON (h.room = h2.room and (pc.effectiveCage = h2.effectiveCage OR (pc.effectiveCage IS NULL and h2.cage IS NULL)))

--account for date/time
WHERE h.enddateTimeCoalesced >= now() and h2.enddateTimeCoalesced >= now()

GROUP BY h.id, h.room, pc.effectiveCage