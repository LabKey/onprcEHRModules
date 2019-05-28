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
  g.rowid,
  g.name,
  group_concat(t2.room) as majorityLocation,
  max(t2.total) as total

FROM ehr.animal_groups g

JOIN (
  SELECT
    t1.groupId,
    max(t1.total) as total
  FROM (
  SELECT
    m.groupId,
    m.Id.curlocation.room,
    count(*) as total
  FROM study.animal_group_members m
  WHERE m.isActive = true
  GROUP BY m.groupId, m.Id.curlocation.room
  ) t1
  GROUP BY t1.groupId
) t ON (t.groupId = g.rowid)

JOIN (
   SELECT
     m.groupId,
     m.Id.curlocation.room,
     count(*) as total
   FROM study.animal_group_members m
   WHERE m.isActive = true
   GROUP BY m.groupId, m.Id.curlocation.room
) t2 ON (t2.groupId = t.groupId AND t.total = t2.total)

GROUP BY g.rowid, g.name