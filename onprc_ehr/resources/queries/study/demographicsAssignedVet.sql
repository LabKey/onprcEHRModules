/*
 * Copyright (c) 2014 LabKey Corporation
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
  COALESCE(c.vetNames, a.vetNames, h.vetNames) as assignedVet,
  COALESCE(c.vetUserIds, a.vetUserIds, h.vetUserIds) as assignedVetId,
  CASE
    WHEN c.vetNames IS NOT NULL THEN 'Active Case'
    WHEN a.vetNames IS NOT NULL THEN 'Assignment'
    --WHEN room.vetNames IS NOT NULL THEN 'Room'
    WHEN h.vetNames IS NOT NULL THEN 'Area'
    ELSE 'None'
  END as assignmentType,
  a.protocols,
  h.areas,
  h.rooms

FROM study.demographics d

LEFT JOIN (
  SELECT
    c.Id,
    group_concat(distinct c.assignedvet.UserId.DisplayName) as vetNames,
    CAST(group_concat(distinct c.assignedvet) as varchar(200)) as vetUserIds
  FROM study.cases c
  WHERE c.isOpen = true
  GROUP BY c.Id
) c ON (c.Id = d.Id)

LEFT JOIN (
  SELECT
    a.Id,
    group_concat(distinct CAST(v.userId.userId.displayName as varchar(120))) as vetNames,
    CAST(group_concat(distinct v.userId) as varchar(200)) as vetUserIds,
    group_concat(distinct a.project.protocol.displayName) as protocols
  FROM study.assignment a
  JOIN onprc_ehr.vet_assignment v ON (a.project.protocol = v.protocol)
  WHERE a.enddateCoalesced >= curdate() OR a.enddate = a.Id.demographics.death
  GROUP BY a.Id
) a ON (a.Id = d.Id)

LEFT JOIN (
  SELECT
    h.Id,
    group_concat(distinct CAST(v.userId.userId.displayName as varchar(120))) as vetNames,
    group_concat(distinct v.userId) as vetUserIds,
    group_concat(distinct h.room.area) as areas,
    group_concat(distinct h.room) as rooms

  FROM study.housing h
  JOIN onprc_ehr.vet_assignment v ON (v.area = h.room.area)
  WHERE h.enddateTimeCoalesced >= now() OR h.enddate = h.Id.demographics.death
  GROUP BY h.Id
) h ON (h.Id = d.Id)

-- LEFT JOIN (
--   SELECT
--     h.Id,
--     group_concat(distinct CAST(v.userId.userId.displayName as varchar(120))) as vetNames,
--     group_concat(distinct v.userId) as vetUserIds
--
--   FROM study.housing h
--   JOIN onprc_ehr.vet_assignment v ON (v.room = h.room)
--   WHERE h.enddateTimeCoalesced >= now() OR h.enddate = h.Id.demographics.death
--   GROUP BY h.Id
-- ) room ON (room.Id = d.Id)