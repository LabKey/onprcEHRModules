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
SELECT * FROM (

select
CASE WHEN t.protocolId IS NULL THEN project WHEN t.protocolId = t.project THEN null ELSE t.project END as project,
CASE WHEN t.protocolId = project THEN RTRIM(ltrim(i2.IACUCCode)) ELSE null END as protocol,
t.species,
t.gender,
t.allowed,
t.start,
t.endDate,
t.objectid

from (

Select
y.projectID as project,
--r.IACUCCode as project,

(select top 1 ipc.projectparentid
  from Ref_ProjectsIACUC rpi2 join Ref_IACUCParentChildren ipc on (rpi2.ProjectID = ipc.ProjectParentID and ipc.datedisabled is null)
  where ipc.projectchildid = r.projectid order by ipc.datecreated desc
) as protocolId,

(select max(rpi2.ts) as maxTs
 from Ref_ProjectsIACUC rpi2 join Ref_IACUCParentChildren ipc on (rpi2.ProjectID = ipc.ProjectParentID and ipc.datedisabled is null)
 where ipc.projectchildid = r.projectid
) as maxTs,

--r.eIACUCNum,
y.CurrentYearStartDate as start,
y.CurrentYearEndDate as endDate,
a.NumAnimalsAssigned as allowed,
CASE
WHEN sp.commonname like '%Cynomolgus%' THEN 'CYNOMOLGUS MACAQUE'
WHEN sp.commonname like '%Rhesus%' THEN 'RHESUS MACAQUE'
WHEN sp.commonname like '%Japanese%' THEN 'JAPANESE MACAQUE'
ELSE sp.CommonName
END as species,
CASE
WHEN s.value = 'Female' then 'f'
WHEN s.value = 'Male' then 'm'
ELSE s.Value
END as gender,
y.objectid

from IACUC_NHPYearly y
join IACUC_NHPAnimals a on (y.NHPYearlyID = a.NHPYearlyID)
join ref_ProjectsIACUC r on (r.ProjectID = y.ProjectID)
left join ref_species sp on (sp.SpeciesCode = a.Species)
left join ref_sex s on (s.Flag = a.Sex)

where (y.DateDisabled is null and a.DateDisabled is Null) and y.CurrentYearEndDate > '1/1/2010'
and (y.ts > ? OR a.ts > ? OR r.ts > ?)

) t

LEFT JOIN Ref_ProjectsIACUC i2 ON (i2.ProjectID = t.protocolId)

WHERE (maxTs > ? or maxTs IS NULL)

) t

WHERE (t.project IS NOT NULL OR t.protocol IS NOT NULL)