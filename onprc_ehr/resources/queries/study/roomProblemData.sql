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
PARAMETERS(StartDate TIMESTAMP, EndDate TIMESTAMP)

SELECT
  t1.lsid,
  t1.room,
  t1.id,
  t1.problemId,
  max(t1.problemOpen) as problemOpen,
  max(t1.problemEnd) as problemEnd,
  t1.category,
  (select count(distinct m.id) FROM study.housing m WHERE (m.dateOnly <= EndDate AND m.enddateCoalesced >= StartDate AND m.room = t1.room)) as totalIdsInRoom,
  StartDate,
  EndDate,
FROM (
  SELECT
    gm.Id,
    gm.room,
    gm.date,
    gm.enddate,
    gm.enddateCoalesced,

    mp.lsid,
    mp.Id as problemId,
    mp.date as problemOpen,
    mp.enddate as problemEnd,
    mp.category,
  FROM study.housing gm

  JOIN study.morbidityAndMortalityData mp ON (
      mp.date <= gm.endDateCoalesced AND
      mp.enddateCoalesced >= gm.date AND
      mp.date <= EndDate AND
      mp.date >= StartDate AND
      gm.id = mp.Id
    )

  WHERE (
    gm.date <= EndDate AND
    gm.enddateCoalesced >= StartDate
  )
) t1

GROUP BY t1.lsid, t1.Id, t1.problemId, t1.room, t1.category