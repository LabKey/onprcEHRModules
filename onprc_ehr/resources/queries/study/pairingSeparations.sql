/*
 * Copyright (c) 2014 LabKey Corporation
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
  p1.date,
  p1.eventtype,
  TIMESTAMPDIFF('SQL_TSI_DAY', p1.date, curdate()) as daysSinceEvent

FROM study.pairings p1
LEFT JOIN study.pairings p2 ON (p1.Id = p2.Id AND p2.date > p1.date)
WHERE p1.eventType = 'Temporary separation' AND TIMESTAMPDIFF('SQL_TSI_DAY', p1.date, curdate()) > 7 AND p2.Id IS NULL
AND p1.Id.demographics.calculated_status = 'Alive'

UNION ALL

SELECT
  p1.Id,
  p1.date,
  p1.eventtype,
  TIMESTAMPDIFF('SQL_TSI_DAY', p1.date, curdate()) as daysSinceEvent

FROM study.pairings p1
LEFT JOIN study.pairings p2 ON (p1.Id = p2.Id AND p2.date > p1.date)
WHERE p1.eventType = 'Extended temporary separation' AND TIMESTAMPDIFF('SQL_TSI_DAY', p1.date, curdate()) > 30 AND p2.Id IS NULL
AND p1.Id.demographics.calculated_status = 'Alive'