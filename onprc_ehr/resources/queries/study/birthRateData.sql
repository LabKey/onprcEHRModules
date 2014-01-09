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
PARAMETERS(StartDate TIMESTAMP, EndDate TIMESTAMP)

SELECT
  d.Id,
  d.birth,

  GROUP_CONCAT(DISTINCT h1.room, chr(10)) as birthRoom,
  GROUP_CONCAT(DISTINCT h1.room.housingType.value, chr(10)) as birthRoomType,

  GROUP_CONCAT(DISTINCT h2.room, chr(10)) as allRooms,
  GROUP_CONCAT(DISTINCT h2.room.housingType.value, chr(10)) as allRoomTypes,

  max(StartDate) as startDate,
  max(EndDate) as endDate,

  CASE
    WHEN d.id.age.ageInDays = 0 THEN 1
    ELSE 0
  END as bornDead,

  CASE
    WHEN (d.death IS NOT NULL AND d.id.age.ageInDays < 365) THEN 1
    ELSE 0
  END as diedBeforeOneYear,

  CASE
    WHEN d.id.age.ageInDays < 365 AND d.death IS NULL THEN 1
    ELSE 0
  END as underOneYrOld,

FROM study.demographics d

JOIN study.housing h1 ON (h1.id = d.Id AND h1.date <= d.birth AND h1.enddateTimeCoalesced >= d.birth)

JOIN study.housing h2 ON (h2.id = d.Id AND h2.dateOnly <= EndDate AND h2.enddateCoalesced >= StartDate)

WHERE cast(d.birth as date) >= StartDate AND cast(d.birth as date) <= EndDate

GROUP BY d.id, d.id.age.ageInDays, d.death, d.birth