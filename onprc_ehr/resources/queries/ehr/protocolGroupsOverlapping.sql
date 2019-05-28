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
  p.rowid,
  p.protocol,
  p.project,
  count(p2.rowid) as totalOverlapping,
  group_concat(distinct p2.rowid, ';') as overlapping

FROM ehr.protocol_counts p
JOIN ehr.protocol_counts p2 ON (
    (p.protocol = p2.protocol OR p.project = p2.project) AND
    (p.rowid != p2.rowid) AND
    (p.start <= p2.enddateCoalesced AND p.enddateCoalesced >= p2.start) AND
    (p.species = p2.species OR (p.species IS NOT NULL AND p2.species IS NULL)) AND
    (p.gender = p2.gender OR (p.gender IS NOT NULL AND p2.gender IS NULL))
    --ignore groups that are immediate parent/children and share the same start/end
    AND NOT(p.start = p2.start AND p.enddateCoalesced = p2.enddateCoalesced AND (p.project.protocol = p2.project.displayName OR p2.project.protocol = p.project.displayName))
)

GROUP BY p.rowid, p.protocol, p.project