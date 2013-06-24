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
select

a.project.investigatorId,
a.id.curLocation.room,
group_concat(distinct a.project.name, ', ') as projects,
count(distinct a.id) as totalAnimals

from study.assignment a

where a.isActive = true and a.id.curLocation.room IS NOT NULL
and a.project.investigatorId IS NOT NULL

group by a.id.curLocation.room, a.project.investigatorId