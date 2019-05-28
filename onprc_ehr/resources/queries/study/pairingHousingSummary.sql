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
  h.Id,
  h.room,
  h.cage,
  h.RoommateId as otherIds,
  h.RoommateStart,
  h.RoommateEnd,
  h.reason,
  null as eventType,
  null as goal,
  null as observation,
  null as outcome,
  null as separationReason,
  null as remark,
  null as performedby,
  null as taskId,
  h.qcstate

FROM study.housingRoommates h

UNION ALL

SELECT

  p.Id,
  p.room,
  p.cage,
  (SELECT group_concat(distinct p2.Id, chr(10)) FROM study.pairings p2 WHERE p.Id != p2.id AND p.pairId = p2.pairId) as otherIds,
  p.date,
  null as RoommateEnd,
  null as reason,
  p.eventType,
  p.goal,
  p.observation,
  p.outcome,
  p.separationreason,
  p.remark,
  p.performedby,
  p.taskid,
  p.qcstate

FROM study.pairings p
