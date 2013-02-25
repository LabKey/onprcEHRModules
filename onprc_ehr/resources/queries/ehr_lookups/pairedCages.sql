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
c.row,
c.column,
c.divider,
c.divider.countAsPaired,
max(np.column) as highestNonPaired,
max(paired.column) as highestPaired,

CASE
  WHEN c.divider.countAsPaired = true then true
  WHEN max(np.column) is null and max(paired.column) is null then false
  WHEN max(np.column) is null and max(paired.column) is not null THEN true --is joined
  WHEN max(np.column) is not null and max(paired.column) is null THEN false --not joined
  WHEN max(np.column) > max(paired.column) THEN false
  ELSE true
END as joined,

CASE
  WHEN max(np.column) is null and max(paired.column) is null then c.cage
  WHEN max(np.column) is null and max(paired.column) is not null THEN (c.row || cast(max(paired.column) as varchar)) --is joined
  WHEN max(np.column) is not null and max(paired.column) is null THEN c.cage --not joined
  WHEN max(np.column) > max(paired.column) THEN c.cage --not joined
  ELSE (c.row || cast(max(paired.column) as varchar))
END as effectiveCage

FROM ehr_lookups.cage c

--find the highest cage with a non-paired divider
LEFT JOIN ehr_lookups.cage np ON (np.cage_type != 'No Cage' and c.room = np.room and c.row = np.row and np.divider.countAsPaired = false and c.column > np.column)

--find the highest cage with a paired divider
LEFT JOIN ehr_lookups.cage paired ON (paired.cage_type != 'No Cage' and c.room = paired.room and c.row = paired.row and paired.divider.countAsPaired = true and c.column > paired.column)

WHERE c.cage_type != 'No Cage'

GROUP BY c.room, c.row, c.cage, c.column, c.divider, c.divider.countAsPaired