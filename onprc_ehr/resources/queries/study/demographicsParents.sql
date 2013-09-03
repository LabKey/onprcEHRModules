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
  coalesce(p2.parent, b.dam) as dam,
  CASE
    WHEN p2.parent IS NOT NULL THEN p2.method
    WHEN b.dam IS NOT NULL THEN 'Observed'
    ELSE null
  END as damType,

  coalesce(p1.parent, b.sire) as sire,
  CASE
    WHEN p1.parent IS NOT NULL THEN p1.method
    WHEN b.sire IS NOT NULL THEN 'Observed'
    ELSE null
  END as sireType,
  CASE
    WHEN (coalesce(p2.parent, b.dam) IS NOT NULL AND coalesce(p1.parent, b.sire) IS NOT NULL) THEN 2
    WHEN (coalesce(p2.parent, b.dam) IS NOT NULL OR coalesce(p1.parent, b.sire) IS NOT NULL) THEN 1
    ELSE 0
  END as numParents
FROM study.demographics d

LEFT JOIN (
  select p1.id, min(p1.method) as method, max(p1.parent) as parent
  FROM study.parentage p1
  WHERE (p1.method = 'Genetic' OR p1.method = 'Provisional Genetic') AND p1.relationship = 'Sire' --AND p1.enddate IS NULL
  GROUP BY p1.Id
) p1 ON (d.Id = p1.id)
LEFT JOIN (
  select p2.id, min(p2.method) as method, max(p2.parent) as parent
  FROM study.parentage p2
  WHERE (p2.method = 'Genetic' OR p2.method = 'Provisional Genetic') AND p2.relationship = 'Dam' --AND p2.enddate IS NULL
  GROUP BY p2.Id
) p2 ON (d.Id = p2.id)
LEFT JOIN study.birth b ON (b.id = d.id)

