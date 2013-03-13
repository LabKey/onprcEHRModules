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

LEFT JOIN study.housing h2 ON (h.room = h2.room and (pc.effectiveCage = h2.cage OR (pc.effectiveCage IS NULL and h2.cage IS NULL)))

WHERE h.enddateCoalesced >= curdate() and h2.enddateCoalesced >= curdate()

GROUP BY h.id, h.room, pc.effectiveCage