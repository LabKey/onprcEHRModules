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
c.room,
c.cage,
c.cagePosition.row,
c.cagePosition.columnIdx,
c.divider,
c.cage_type,
c.divider.countAsPaired,
max(np.cagePosition.columnIdx) as highestNonPaired,
max(paired.cagePosition.columnIdx) as highestPaired,

CASE
  WHEN c.divider.countAsPaired = true then true
  WHEN max(np.cagePosition.columnIdx) is null and max(paired.cagePosition.columnIdx) is null then false
  WHEN max(np.cagePosition.columnIdx) is null and max(paired.cagePosition.columnIdx) is not null THEN true --is joined
  WHEN max(np.cagePosition.columnIdx) is not null and max(paired.cagePosition.columnIdx) is null THEN false --not joined
  WHEN max(np.cagePosition.columnIdx) > max(paired.cagePosition.columnIdx) THEN false
  ELSE true
END as joined,

CASE
  WHEN max(np.cagePosition.columnIdx) is null and max(paired.cagePosition.columnIdx) is null then c.cage
  WHEN max(np.cagePosition.columnIdx) is null and max(paired.cagePosition.columnIdx) is not null THEN (c.cagePosition.row || cast(max(paired.cagePosition.columnIdx) as varchar)) --is joined
  WHEN max(np.cagePosition.columnIdx) is not null and max(paired.cagePosition.columnIdx) is null THEN c.cage --not joined
  WHEN max(np.cagePosition.columnIdx) > max(paired.cagePosition.columnIdx) THEN c.cage --not joined
  ELSE (c.cagePosition.row || cast(max(paired.cagePosition.columnIdx) as varchar))
END as effectiveCage

FROM ehr_lookups.cage c

--find the highest cage with a non-paired divider
LEFT JOIN ehr_lookups.cage np ON (np.cage_type != 'No Cage' and c.room = np.room and c.cagePosition.row = np.cagePosition.row and np.divider.countAsPaired = false and c.cagePosition.columnIdx > np.cagePosition.columnIdx)

--find the highest cage with a paired divider
LEFT JOIN ehr_lookups.cage paired ON (paired.cage_type != 'No Cage' and c.room = paired.room and c.cagePosition.row = paired.cagePosition.row and paired.divider.countAsPaired = true and c.cagePosition.columnIdx > paired.cagePosition.columnIdx)

WHERE c.cage_type != 'No Cage'

GROUP BY c.room, c.cagePosition.row, c.cage, c.cagePosition.columnIdx, c.divider, c.divider.countAsPaired, c.cage_type