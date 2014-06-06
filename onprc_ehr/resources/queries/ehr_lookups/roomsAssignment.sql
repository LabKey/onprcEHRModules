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
select

  a.room,
  group_concat(distinct a.name, chr(10)) as projects,
  group_concat(distinct a.investigator, chr(10)) as investigators,

  group_concat(distinct a.projectIdTotal, chr(10)) as projectIdCount,
  group_concat(distinct a.projectCageTotal, chr(10)) as projectCageCount,

  sum(a.totalAnimals) as totalAssignments

FROM (

select
  a.id.curLocation.room as room,
  a.project.name as name,
  a.project.investigatorId.lastname as investigator,
  cast(a.project.name || ' (' || a.project.investigatorId.lastname || '): ' || cast(count(distinct a.Id) as varchar) as varchar) as projectIdTotal,
  cast(a.project.name || ' (' || a.project.investigatorId.lastname || '): ' || cast(count(distinct a.id.curLocation.cage) as varchar) as varchar) as projectCageTotal,
  count(distinct a.id) as totalAnimals

from study.assignment a
where a.isActive = true and a.id.curLocation.room IS NOT NULL
group by a.id.curLocation.room, a.project.name, a.project.investigatorId.lastname

) a

group by a.room