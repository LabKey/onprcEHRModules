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
  d.id,
  d.id.curLocation.room,
  d.id.curLocation.cage,
  d.id.age.ageInDays,

  d2.dam as dam,
  dl.room as damRoom,
  dl.cage as damCage,

FROM study.demographics d

LEFT JOIN study.demographicsParents d2 ON (d.id = d2.id)

LEFT JOIN study.demographicsCurrentLocation dl ON (d2.dam = dl.id)

WHERE d.id.curLocation.room != dl.room AND coalesce(d.id.curLocation.cage, '') != coalesce(dl.cage, '')