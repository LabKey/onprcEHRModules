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
  t1.project,
  t1.Id,
  max(t1.date) as problemOpen,
  max(t1.enddate) as problemEnd,
  t1.category,
  t1.problemId,

  max(StartDate) as StartDate,
  max(EndDate) as Enddate,

FROM (
  SELECT
    gm.Id,
    gm.project,

    mp.lsid,
    mp.date,
    mp.enddate,
    mp.category,
    mp.Id as problemId,
  FROM study.assignment gm

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

GROUP BY t1.lsid, t1.Id, t1.problemId, t1.project, t1.category