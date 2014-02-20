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
  p.Id,
  p.relationship,

  group_concat(distinct p.parent) as parents,
  group_concat(distinct p.method) as method,
  'Duplicate Parents With Same Relationship' as type,
  count(p.Id) as totalRecords

FROM study.parentage p
WHERE p.qcstate.publicdata = true and p.enddateCoalesced <= now()
AND p.relationship != 'Surrogate Dam' and p.relationship != 'Foster Dam' and p.enddateCoalesced >= curdate()

GROUP BY p.Id, p.relationship
HAVING COUNT(DISTINCT p.parent) > 1

-- UNION ALL
--
-- SELECT
--   p.Id,
--   p.relationship,
--   p.parent as parents,
--   group_concat(distinct p.method) as method,
--   'Duplicate Methods For The Same Parent' as type,
--   count(p.Id) as totalRecords
--
-- FROM study.parentage p
-- WHERE p.qcstate.publicdata = true and p.enddateCoalesced <= now()
-- AND p.relationship != 'Surrogate Dam' and p.relationship != 'Foster Dam' and p.enddateCoalesced >= curdate()
--
-- GROUP BY p.Id, p.relationship, p.parent
-- HAVING COUNT(distinct p.method) > 1