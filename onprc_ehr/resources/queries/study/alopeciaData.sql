/*
 * Copyright (c) 2014-2017 LabKey Corporation
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
o.Id,
o.taskId,
o.Id.Demographics.species as Specie,
o.Id.demographics.gender as Gender,
max(o.date) as date,
o.dateMonthNumber as MonthNumber,
o.ageAtTime.AgeAtTimeYearsRounded as AgeTimeYears,
o.category,
(SELECT group_concat(distinct d.code.meaning) as code FROM study.drug d WHERE d.Id = o.Id AND d.taskId = o.taskId AND d.code IN ('E-70590', 'E-YY992')) as sedation,
group_concat(DISTINCT o.observation, ',') as observation,
group_concat(DISTINCT o.remark, ',') as remark,
max(o.performedby) as performedBy,
max(o.housingAtTime.RoomAtTime) as RoomAtTime,
max(o.groupsAtTime.groupsAtTime) as GroupAtTime,
(SELECT group_concat(distinct room) as rooms FROM study.housing h
WHERE h.Id = o.Id
  AND h.date <= max(o.date)
  AND h.enddateTimeCoalesced >= timestampadd('SQL_TSI_DAY', -30, max(o.date))
) as rooms,
(SELECT group_concat(distinct room.area) as areas FROM study.housing h
WHERE h.Id = o.Id
  AND h.date <= max(o.date)
  AND h.enddateTimeCoalesced >= timestampadd('SQL_TSI_DAY', -30, max(o.date))
) as areas

FROM study.clinical_observations o
WHERE o.category IN ('Alopecia Score', 'Alopecia Type', 'Alopecia Regrowth')
--note: this is a fairly arbitrary cutoff, used because we only started tracking these measures after this date
and date > '2014-05-01'
GROUP BY o.Id, o.taskId, o.Id.Demographics.species, o.Id.demographics.gender,o.dateMonthNumber,o.ageAtTime.AgeAtTimeYearsRounded , o.category
PIVOT observation,remark BY category IN ('Alopecia Score', 'Alopecia Type', 'Alopecia Regrowth')
