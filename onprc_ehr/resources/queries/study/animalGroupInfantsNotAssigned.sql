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
  d.Id,
  d.Id.parents.dam,
  gm.groupId as damGroupId,
  gm2.groupId as offspringGroupId,
  d.birth,
  CASE
    WHEN gm2.Id IS NULL THEN false
    ELSE true
  END as matchesDamGroup

FROM study.demographics d

--find dams with group assignments on date of birth
JOIN study.animal_group_members gm ON (d.Id.parents.dam = gm.id AND gm.dateOnly <= cast(d.birth as date) AND gm.enddateCoalesced >= cast(d.birth as date))

LEFT JOIN study.animal_group_members gm2 ON (gm.groupId = gm2.groupId AND d.Id = gm2.Id AND gm2.dateOnly <= cast(d.birth as date) AND gm2.enddateCoalesced >= cast(d.birth as date))

