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
 pc.room,
 pc.effectiveCage as cage,
 count(DISTINCT h.id) as totalAnimals,
 group_concat(h.id, chr(10)) as animals,
 group_concat(DISTINCT h.cage) as cagesOccupied,
 group_concat(DISTINCT pc.cage) as cagesJoined,
 CASE
    WHEN (count(DISTINCT h.id) > 1) THEN 1
    ELSE 0
 END as isPaired,

FROM ehr_lookups.pairedCages pc
left join study.housing h ON (pc.room = h.room AND pc.cage = h.cage AND h.qcstate.publicdata = true and h.enddate is null and h.room.housingType.value = 'Cage Location')

GROUP BY pc.room, pc.effectiveCage