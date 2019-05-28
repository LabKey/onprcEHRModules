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
  b.Id,
  b.date as birth,
  h.Id as potentialDam,
  b.room as birthRoom,
  b.cage as birthCage,
  --NOTE: SQL_TSI_YEAR not support in postgres
  (timestampdiff('SQL_TSI_DAY', h.Id.demographics.birth, b.date) / 365) as damAgeAtTime

FROM study.birth b

JOIN study.housing h ON (
    (b.Id != h.Id AND
    h.dateOnly <= b.dateOnly AND
    h.enddateCoalesced >= b.dateOnly AND
    h.room = b.room AND (h.cage = b.cage OR (h.cage is null and b.cage is null))
    )
    --note: this is to always include observed parents
    OR h.Id = b.dam
)

WHERE h.id.demographics.gender = 'f' and timestampdiff('SQL_TSI_DAY', h.Id.demographics.birth, b.date) > 912.5 --(2.5 years)
AND h.Id.demographics.species = b.Id.demographics.species

GROUP BY b.Id, b.date, b.room, b.cage, h.Id, h.Id.demographics.birth