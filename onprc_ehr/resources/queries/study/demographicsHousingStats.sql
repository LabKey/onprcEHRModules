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
  t.Id,
  t.dateOfLastCageHousing,
  timestampdiff('SQL_TSI_DAY', t.dateOfLastCageHousing, now()) as daysSinceLastCageHousing,
  t.dateOfLastGroupHousing,
  timestampdiff('SQL_TSI_DAY', t.dateOfLastGroupHousing, now()) as daysSinceLastGroupHousing,
  t.dateOfLastCagemate,
  timestampdiff('SQL_TSI_DAY', t.dateOfLastCagemate, now()) as daysSinceLastCagemate

FROM (
SELECT
  h.Id,
  MAX(CASE
    WHEN h.room.housingType.value = 'Cage Location' THEN h.enddateTimeCoalesced
    ELSE null
  END) as dateOfLastCageHousing,
  MAX(CASE
    WHEN h.room.housingType.value = 'Group Location' THEN h.enddateTimeCoalesced
    ELSE null
  END) as dateOfLastGroupHousing,
  max(h2.date) as dateOfLastCagemate

FROM study.housing h
LEFT JOIN study.housing h2
  ON (h2.room = h.room AND h.Id != h2.Id AND (h.cage = h2.cage OR (h2.cage IS NULL AND h.cage IS NULL)))

GROUP BY h.Id

) t