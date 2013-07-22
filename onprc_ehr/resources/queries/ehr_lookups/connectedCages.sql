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
c.divider.countAsSeparate,
max(joined.cagePosition.columnIdx) as highestNonSeparate,
max(sep.cagePosition.columnIdx) as highestSeparate,


CASE
  WHEN max(joined.cagePosition.columnIdx) is null and max(sep.cagePosition.columnIdx) is null then false
  WHEN max(joined.cagePosition.columnIdx) is null and max(sep.cagePosition.columnIdx) is not null THEN false
  WHEN max(joined.cagePosition.columnIdx) is not null and max(sep.cagePosition.columnIdx) is null THEN true
  WHEN max(joined.cagePosition.columnIdx) < max(sep.cagePosition.columnIdx) THEN false --not joined
  ELSE true
END as joined,

-- case
--   WHEN count(v.cage) = 0 THEN false
--   ELSE true
-- END as verticalJoin,

CASE
  WHEN max(joined.cagePosition.columnIdx) is null and max(sep.cagePosition.columnIdx) is null then (c.cage)
  WHEN max(joined.cagePosition.columnIdx) is null and max(sep.cagePosition.columnIdx) is not null THEN (c.cage)
  WHEN max(joined.cagePosition.columnIdx) is not null and max(sep.cagePosition.columnIdx) is null THEN (c.cagePosition.row || cast(min(joined.cagePosition.columnIdx) as varchar)) --is joined
  WHEN max(joined.cagePosition.columnIdx) < max(sep.cagePosition.columnIdx) THEN (c.cage) --not joined
  ELSE (c.cagePosition.row || cast(max(joined.cagePosition.columnIdx) as varchar))
END as effectiveCage

FROM ehr_lookups.cage c

--NOTE: something like this could be used to handle vertical joined.
-- --find any vertical joins.  if verticalCage slots > 1.  preferentially use this row in the future
-- LEFT JOIN ehr_lookups.cage v ON (v.cage_type != 'No Cage' and c.room = v.room and c.cagePosition.columnIdx = v.cagePosition.columnIdx and (ASCII(c.cagePosition.row) > ASCII(v.cagePosition.row)) AND (ASCII(c.cagePosition.row) - ASCII(v.cagePosition.row)) < c.cage_type.verticalSlots AND mod(ASCII(c.cagePosition.row), 2) = 0)

--for the next 2 horizontal joins, use the highest effective row, determined above
--find the highest cage with a non-separating divider
LEFT JOIN ehr_lookups.cage joined ON (joined.cage_type != 'No Cage' and c.room = joined.room and c.cagePosition.row = joined.cagePosition.row and joined.divider.countAsSeparate = false and c.cagePosition.columnIdx > joined.cagePosition.columnIdx)

--find the highest cage with a separating divider
LEFT JOIN ehr_lookups.cage sep ON (sep.cage_type != 'No Cage' and c.room = sep.room and c.cagePosition.row = sep.cagePosition.row and sep.divider.countAsSeparate = true and c.cagePosition.columnIdx > sep.cagePosition.columnIdx)

WHERE c.cage_type != 'No Cage'

GROUP BY c.room, c.cagePosition.row, c.cage, c.cagePosition.columnIdx, c.divider, c.divider.countAsSeparate, c.cage_type