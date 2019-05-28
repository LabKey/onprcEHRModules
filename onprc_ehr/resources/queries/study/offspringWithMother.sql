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
  h1.id,
  h2.id as dam,
  h1.room,
  h1.cage,
  h1.id.age.ageInDays,

FROM study.housing h1
JOIN study.housing h2 ON (h1.id.parents.dam = h2.id AND h1.room = h2.room AND (h1.cage = h2.cage OR (h1.cage IS NULL AND h2.cage IS NULL)))
WHERE h1.enddateTimeCoalesced >= now() AND h2.enddateTimeCoalesced >= now()