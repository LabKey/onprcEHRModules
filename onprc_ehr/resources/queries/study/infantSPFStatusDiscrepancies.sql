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
  d.Id,
  d.Id.parents.dam,
  gm.flag.value as damStatus,
  f.flag.value as offspringStatus,
  d.birth,
  CASE
    WHEN (gm.flag IS NULL AND f.flag IS NULL) THEN true
    WHEN (gm.flag = f.flag) THEN true
    ELSE false
  END as matchesDamStatus

FROM study.demographics d

--find SPF status on birth date
LEFT JOIN study.flags f ON (
  f.Id = d.Id AND
  f.dateOnly <= CAST(d.birth as date) AND
  f.enddateCoalesced >= CAST(d.birth as date) AND
  f.flag.category = 'SPF'
)
--find dam SPF status on birth date
LEFT JOIN study.flags gm ON (
  d.Id.parents.dam = gm.id AND
  gm.dateOnly <= cast(d.birth as date) AND
  gm.enddateCoalesced >= cast(d.birth as date) AND
  gm.flag.category = 'SPF'
)