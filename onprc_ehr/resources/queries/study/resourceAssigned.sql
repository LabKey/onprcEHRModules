/*
 * Copyright (c) 2017 LabKey Corporation
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
SELECT assignment.Id,
--assignment.project,
Max(assignment.project.protocol) as protocol,
--assignment.Cohort,
--assignment.date,
--assignment.enddate,
--assignment.project.use_category,
v.userId.displayName as vetAssigned
FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.assignment left outer join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.Vet_Assignment v on assignment.project.protocol = v.protocol.protocol
where project.use_category != 'research' and enddate is null
group by assignment.id, v.userId.displayName