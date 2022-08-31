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
 * 2022-08-23 Changed source of assignment data to linked schema working to get in correct location
 */
select

  a.room,
  group_concat(distinct a.name, chr(10)) as projects,
  group_concat(distinct a.investigator, chr(10)) as investigators,

  group_concat(distinct a.projectIdTotal, chr(10)) as projectIdCount,
  group_concat(distinct a.projectCageTotal, chr(10)) as projectCageCount,

  sum(a.totalAnimals) as totalAssignments

FROM (select
    h.room as room,
    p.name as name,
    i.lastname as investigator,
  cast(p.name || ' (' || i.lastname || '): ' || cast(count(distinct a.Id) as varchar) as varchar) as projectIdTotal,
  cast(p.name || ' (' || i.lastname || '): ' || cast(count(distinct h.cage) as varchar) as varchar) as projectCageTotal,
  count(distinct a.id) as totalAnimals
from finance_study.assignment a
	left outer join finance_study.housing h on a.id = h.id and (h.enddate is null or h.enddate > Now())
	left outer join pf_publicEHR.project p on a.project = p.project
	left outer join pf_onprcEHRPublic.investigators i on i.rowid = p.investigatorId
where a.isActive = true
group by h.room, p.name, i.lastname
) a

group by a.room