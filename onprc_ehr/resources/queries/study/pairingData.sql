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
  p1.Id,
  p1.Id2,
  p1.date,
  p1.pairingType,
  p1.pairingOutcome,
  p1.separationReason,
  p1.aggressor,
  p1.room1,
  p1.cage1,
  p1.room2,
  p1.cage2,
  p1.remark,
  p1.performedby

FROM study.pairings p1

UNION ALL

SELECT
  p2.Id2 as Id,
  p2.Id as Id2,
  p2.date,
  p2.pairingType,
  p2.pairingOutcome,
  p2.separationReason,
  p2.aggressor,
  p2.room2 as room1,
  p2.cage2 as cage1,
  p2.room1 as room2,
  p2.cage1 as cage2,
  p2.remark,
  p2.performedby

FROM study.pairings p2
