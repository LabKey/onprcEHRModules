/*
 * Copyright (c) 2014-2017 LabKey Corporation
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
select a.project as project,
a.name as centerproject,
b.external_id as Protocol,
g.lastname as investigator,
  ( a.name + '-' + ' [' + g.LastName + ' - ' + b.external_id + ']' ) as projectname ,
   ( b.external_id + '-' + ' [' + g.LastName + ' - ' + a.name + ']' ) as protocolname ,
  a.enddate as enddate

 from  ehr.project a
left join  ehr.protocol b on(rtrim(a.protocol)= rtrim(b.protocol))
 left join  onprc_ehr.investigators g on (g.rowId = a.investigatorId)
where ( a.enddate is null or a.enddate >= Now())


order by centerproject
