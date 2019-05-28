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
  b.id.demographics.species,

  count(b.Id) as totalIds,
  sum(b.bornDead) as totalBornDead,
  sum(b.diedBeforeOneYear) as totalDiedBeforeOneYear,
  count(b.Id) - sum(b.diedBeforeOneYear) as totalSurvivedOneYear,

  max(StartDate) as startDate,
  max(EndDate) as endDate

FROM study.birthRateData b

GROUP BY b.id.demographics.species