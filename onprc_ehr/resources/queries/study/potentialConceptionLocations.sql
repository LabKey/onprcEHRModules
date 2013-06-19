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
  b1.Id,
  h1.room,
  h1.cage,
  group_concat(DISTINCT h1.Id) as potentialDams,
  min(b1.minDate) as minDate,
  min(b1.maxDate) as maxDate

FROM (

SELECT
  b.Id,
  b.potentialDam,
  b.birth,
  timestampadd('SQL_TSI_DAY', -180, b.birth) as minDate,
  timestampadd('SQL_TSI_DAY', -155, b.birth) as maxDate

FROM study.potentialDams b

) b1

--find all housing records for these females overlapping the conception window
JOIN study.housing h1 ON (
  h1.Id = b1.potentialDam AND
  h1.date <= b1.maxDate AND 
  h1.enddateTimeCoalesced >= b1.minDate
)

GROUP BY b1.Id, h1.room, h1.cage