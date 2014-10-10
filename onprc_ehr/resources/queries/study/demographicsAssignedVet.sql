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
  COALESCE(c.vetNames, h.highPriRoomVetNames, h.highPriAreaVetNames, a.vetNames, h.roomVetNames, h.areaVetNames) as assignedVet,
  --COALESCE(c.vetUserIds, h.highPriRoomVetUserIds, h.highPriAreaVetUserIds, a.vetUserIds, h.roomVetUserIds, h.areaVetUserIds) as assignedVetId,
  CASE
    WHEN (c.vetNames IS NOT NULL) THEN 'Active Case'
    WHEN (h.highPriRoomVetNames IS NOT NULL) THEN 'Room (Priority)'
    WHEN (h.highPriAreaVetNames IS NOT NULL) THEN 'Area (Priority)'
    WHEN (a.vetNames IS NOT NULL) THEN 'Assignment'
    WHEN (h.roomVetNames IS NOT NULL) THEN 'Room'
    WHEN (h.areaVetNames IS NOT NULL) THEN 'Area'
    ELSE 'None'
  END as assignmentType,
  a.protocols,
  h.areas,
  h.rooms

FROM study.demographics d

LEFT JOIN (
  SELECT
    c.Id,
    group_concat(distinct c.assignedvet.DisplayName) as vetNames,
    CAST(group_concat(distinct c.assignedvet) as varchar(200)) as vetUserIds
  FROM study.cases c
  --WHERE c.isOpen = true
  WHERE c.enddateCoalesced >= curdate() OR CAST(c.enddate AS DATE) = CAST(c.Id.demographics.lastDayAtCenter AS DATE)
  GROUP BY c.Id
) c ON (c.Id = d.Id)

LEFT JOIN (
  SELECT
    a.Id,
    group_concat(distinct CAST(v.userId.displayName as varchar(120))) as vetNames,
    CAST(group_concat(distinct v.userId) as varchar(200)) as vetUserIds,
    group_concat(distinct a.project.protocol.displayName) as protocols
  FROM study.assignment a
  JOIN onprc_ehr.vet_assignment v ON (a.project.protocol = v.protocol)
  WHERE a.enddateCoalesced >= curdate() OR CAST(a.enddateCoalesced AS DATE) = CAST(a.Id.demographics.lastDayAtCenter AS DATE)
  GROUP BY a.Id
) a ON (a.Id = d.Id)

LEFT JOIN (
  SELECT
    h.Id,
    group_concat(distinct CASE WHEN (v.area IS NOT NULL) THEN CAST(v.userId.displayName as varchar(120)) ELSE NULL END) as areaVetNames,
    group_concat(distinct CASE WHEN (v.room IS NOT NULL) THEN CAST(v.userId.displayName as varchar(120)) ELSE NULL END) as roomVetNames,
    group_concat(distinct CASE WHEN (v.area IS NOT NULL and v.priority = true) THEN CAST(v.userId.displayName as varchar(120)) ELSE NULL END) as highPriAreaVetNames,
    group_concat(distinct CASE WHEN (v.room IS NOT NULL and v.priority = true) THEN CAST(v.userId.displayName as varchar(120)) ELSE NULL END) as highPriRoomVetNames,

    group_concat(distinct CASE WHEN (v.area IS NOT NULL) THEN v.userId ELSE NULL END) as areaVetUserIds,
    group_concat(distinct CASE WHEN (v.room IS NOT NULL) THEN v.userId ELSE NULL END) as roomVetUserIds,
    group_concat(distinct CASE WHEN (v.area IS NOT NULL and v.priority = true) THEN v.userId ELSE NULL END) as highPriAreaVetUserIds,
    group_concat(distinct CASE WHEN (v.room IS NOT NULL and v.priority = true) THEN v.userId ELSE NULL END) as highPriRoomVetUserIds,

    group_concat(distinct h.room.area) as areas,
    group_concat(distinct h.room) as rooms

  FROM study.housing h
  JOIN onprc_ehr.vet_assignment v ON (v.area = h.room.area OR v.room = h.room)
  WHERE h.enddateTimeCoalesced >= now() OR CAST(h.enddateCoalesced AS DATE) = CAST(h.Id.demographics.lastDayAtCenter AS DATE)
  GROUP BY h.Id
) h ON (h.Id = d.Id)