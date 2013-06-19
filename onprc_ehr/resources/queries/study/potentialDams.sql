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
  b.Id,
  b.date as birth,
  h.Id as potentialDam,
  b.room as birthRoom,
  b.cage as birthCage

FROM study.birth b

JOIN study.housing h ON (
    h.date <= b.date AND
    h.enddateCoalesced >= b.date AND
    h.room = b.room AND (h.cage = b.cage OR (h.cage is null and b.cage is null))
)

WHERE h.id.demographics.gender = 'f'
