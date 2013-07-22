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
p.room,
p.effectiveCage,
group_concat(p.cage) as cages,
count(p.cage) as numCages,
group_concat(distinct p.cage_type) as cageTypes,
--sum(p.cage_type.cageSlots) as expectedCageSlots,

-- this is sort of a hack.  we really should correctly size our cages
sum(p.cage_type.sqft / p.cage_type.cageSlots) as totalSqFt

FROM ehr_lookups.pairedCages p

GROUP BY p.room, p.effectiveCage