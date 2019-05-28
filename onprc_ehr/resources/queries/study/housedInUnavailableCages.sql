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
  h.id,
  h.room,
  h.cage,
  h.date,
  h.enddate,
  c.cage_type,
  c.divider,
  c.effectiveCage as expectedCage
FROM study.housing h
LEFT JOIN ehr_lookups.connectedCages c ON (c.room = h.room AND c.cage = h.cage)

--WHERE h.isActive = true
  WHERE h.enddateTimeCoalesced >= now()

AND h.cage IS NOT NULL AND (h.cage != c.effectiveCage OR c.effectiveCage IS NULL) and h.room.housingType.value = 'Cage Location'