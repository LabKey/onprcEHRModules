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
  group_concat(DISTINCT a.project.name, chr(10)) as projects,
  group_concat(DISTINCT a.project.investigatorId.lastName, chr(10)) as investigators,
  COALESCE(count(distinct a.project.name), 0) as totalProjects,
  COALESCE(count(a.lsid), 0) as numAssignments,
  max(a.enddateCoalesced) as dateLastAssigned,
  timestampdiff('SQL_TSI_DAY', max(a.enddateCoalesced), now()) as daysSinceLastAssignment

FROM study.demographics d
LEFT JOIN study.assignment a ON (a.id = d.id)
GROUP BY d.id