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
  h1.room.area as area,
  h1.room,
  group_concat(DISTINCT h1.status, chr(10)) as viralStatuses,
  count(DISTINCT h1.viralStatus) as distinctStatuses

FROM (
SELECT
  h.room,
  h.Id.viral_status.viralStatus as viralStatus,
  count(distinct h.id) as totalAnimals,
  h.Id.viral_status.viralStatus || ' (' || cast(count(distinct h.id) as varchar) || ')' as status,

FROM study.housing h
WHERE h.enddateTimeCoalesced >= now()
GROUP BY h.room, h.Id.viral_status.viralStatus

) h1
GROUP BY h1.room, h1.room.area


