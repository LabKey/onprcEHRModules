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
  coalesce(p2.parent, b.dam, p5.parent) as dam,
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
  p2.parent as geneticdam,
  p2.method as geneticdamtype,
  p3.parent as fostermom,
  p3.method as fostertype,
  p4.parent as surrogatedam,
  coalesce(b.dam,p5.parent) as observeddam,

  (CASE WHEN p3.parent IS NOT NULL THEN 1 ELSE 0 END +
  CASE WHEN p4.parent IS NOT NULL THEN 1 ELSE 0 END +
  CASE WHEN coalesce(p2.parent, b.dam) IS NOT NULL THEN 1 ELSE 0 END +
  CASE WHEN coalesce(p1.parent, b.sire) IS NOT NULL THEN 1 ELSE 0 END) as numParents,
  greatest(d.modified, p1.modified, p2.modified, p3.modified, p4.modified,p5.modified, b.modified) as modified
FROM  study.demographics d

LEFT JOIN (
  select p1.id, min(p1.method) as method, max(p1.parent) as parent, max(p1.modified) as modified
  FROM study.parentage p1
  WHERE p1.method in ('Genetic','Provisional Genetic')  AND p1.relationship = 'Sire' AND p1.enddate IS NULL
  GROUP BY p1.Id
) p1 ON (d.Id = p1.id)

LEFT JOIN (
  select p2.id, min(p2.method) as method, max(p2.parent) as parent, max(p2.modified) as modified
  FROM study.parentage p2
  WHERE p2.method in ('Genetic','Provisional Genetic') AND p2.relationship = 'Dam' AND p2.enddate IS NULL
  GROUP BY p2.Id
) p2 ON (d.Id = p2.id)

LEFT JOIN (
  select p3.id, min(p3.method) as method, max(p3.parent) as parent, max(p3.modified) as modified
  FROM study.parentage p3
  WHERE p3.relationship = 'Foster Dam' AND p3.enddate IS NULL
  GROUP BY p3.Id
) p3 ON (d.Id = p3.id)
LEFT JOIN (
    select p4.id, min(p4.method) as method, max(p4.parent) as parent, max(p4.modified) as modified
    FROM study.parentage p4
    WHERE p4.relationship = 'Surrogate Dam' AND p4.enddate IS NULL
    GROUP BY p4.Id
) p4 ON (d.Id = p4.id)

LEFT JOIN (
    select p5.id, min(p5.method) as method, max(p5.parent) as parent, max(p5.modified) as modified
    FROM study.parentage p5
    WHERE p5.relationship = 'Observed' AND p5.enddate IS NULL
    GROUP BY p5.Id
) p5 ON (d.Id = p5.id)

LEFT JOIN study.birth b ON (b.id = d.id)

