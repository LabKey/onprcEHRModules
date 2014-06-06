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
  t1.groupId,
  group_concat(t1.roomSummary, chr(10)) as roomSummary,
  count(distinct t1.roomSummary) as totalRooms

FROM (

SELECT
  gm.groupId,
  gm.Id.curLocation.room,
  count(distinct gm.id) as totalAnimals,
  gm.Id.curLocation.room || ' (' || cast(count(distinct gm.id) as varchar) || ')' as roomSummary

FROM study.animal_group_members gm

WHERE gm.enddateCoalesced >= curdate() and gm.Id.curLocation.area != 'Hospital'
GROUP BY gm.groupId, gm.Id.curLocation.room

) t1

GROUP BY t1.groupId