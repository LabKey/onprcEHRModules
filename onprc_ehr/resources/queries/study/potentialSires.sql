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
  c.Id,
  h.Id as potentialSire,
  group_concat(DISTINCT h.room) as rooms,
  group_concat(DISTINCT h.cage) as cages,
  --NOTE: SQL_TSI_YEAR not support in postgres
  (max(timestampdiff('SQL_TSI_DAY', h.Id.demographics.birth, c.minDate)) / 365) as sireAgeAtTime

FROM study.potentialConceptionLocations c

--then find all males overlapping with these locations that also overlap with the conception window
JOIN study.housing h ON ((
    h.Id.demographics.gender = 'm' AND
    h.room = c.room AND
    (h.cage = c.cage OR (h.cage IS NULL AND c.cage IS NULL)) AND
    h.dateOnly <= cast(c.maxDate as date) AND h.enddateCoalesced >= cast(c.minDate as date)
)

--note: this is to always include all observed sires
OR h.Id = c.Id.birth.sire
)

WHERE timestampdiff('SQL_TSI_DAY', h.Id.demographics.birth, c.minDate) > 912.5 --(2.5 years)
AND h.Id.demographics.species = c.Id.demographics.species

GROUP BY c.Id, h.Id