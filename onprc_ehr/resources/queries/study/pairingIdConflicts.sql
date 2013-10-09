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
  p.lowestCage,
  p.room,
  p.taskId,
  count(*) as total,
  group_concat(p.Id) as Ids

FROM study.pairings p
WHERE taskId is not null
GROUP BY p.taskId, p.lowestCage, p.room
HAVING COUNT(distinct p.pairId) > 1