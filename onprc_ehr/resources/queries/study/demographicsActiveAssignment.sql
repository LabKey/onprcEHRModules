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
  a.id,
  group_concat(DISTINCT a.projectString, chr(10)) as projectAndInvestigator,
  group_concat(DISTINCT a.displayName, chr(10)) as projects,
  group_concat(DISTINCT a.protocolDisplayName, chr(10)) as protocols,
  group_concat(DISTINCT cast(a.lastName as varchar), chr(10)) as investigators,
  group_concat(DISTINCT cast(a.division as varchar), chr(10)) as divisions,
  group_concat(DISTINCT a.lastName, chr(10)) as vets,
  COALESCE(count(distinct a.projectName), 0) as totalProjects,
  COALESCE(count(a.lsid), 0) as numActiveAssignments,
  COALESCE(SUM(a.isResearch), 0) as numResearchAssignments,
  COALESCE(SUM(a.isResource), 0) as numResourceAssignments,
  COALESCE(SUM(a.isU24U42), 0) as numU24U42Assignments,
  COALESCE(SUM(a.isProvisional), 0) as numProvisionalAssignments

FROM (

SELECT
  d.id,
  a.project.displayName as displayName,
  a.project.protocol.displayName as protocolDisplayName,
  a.project.investigatorId.lastName as lastName,
  a.project.investigatorId.division as division,
  a.project.name as projectName,
  a.lsid,
  a.project.isResearch as isResearch,
  a.project.isResource as isResource,
  a.project.isU24U42 as isU24U42,
  0 as isProvisional,
  cast(CASE
    WHEN a.project.investigatorId IS NOT NULL THEN (a.project.investigatorId.lastName || ' [' || a.project.name || ']')
    ELSE a.project.name
  END as varchar(500)) as projectString

FROM study.demographics d
LEFT JOIN study.assignment a ON (a.id = d.id AND a.isActive = true)

UNION ALL

SELECT
  d.id,
  f.flag.value as displayName,
  f.flag.value as protocolDisplayName,
  f.flag.value as lastName,
  f.flag.value as division,
  f.flag.value as projectName,
  null as lsid,  --we do not want these counted in total assignments
  0 as isResearch,
  0 as isResource,
  0 as isU24U42,
  CASE WHEN f.Id IS NULL THEN 0 ELSE 1 END as isProvisional,
  f.flag.value as projectString

FROM study.demographics d
JOIN study.flags f ON (f.id = d.id AND f.isActive = true AND f.flag.category = 'Assign Alias')

) a

GROUP BY a.id