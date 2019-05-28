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
  t.id,
  max(t.status) as withMother

FROM (

SELECT
  d.id,
  CASE
    WHEN (d.id.curLocation.room = dl.room AND coalesce(d.id.curLocation.cage, '') = coalesce(dl.cage, '')) THEN 1
    ELSE 0
  END as status,

FROM study.demographics d

LEFT JOIN study.parentageSummary d2 ON (d.id = d2.Id and d2.relationship like '%Dam%')

LEFT JOIN study.demographicsCurrentLocation dl ON (d2.parent = dl.id)

) t

GROUP BY t.Id