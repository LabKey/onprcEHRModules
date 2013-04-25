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
Select
y.projectID as project,
--r.IACUCCode as project,
--r.eIACUCNum,
y.CurrentYearStartDate as start,
y.CurrentYearEndDate as endDate,
a.NumAnimalsAssigned as allowed,
CASE
  WHEN sp.commonname = 'Cynomolgus' THEN 'CYNOMOLGUS MACAQUE'
  WHEN sp.commonname = 'Rhesus' THEN 'RHESUS MACAQUE'
  WHEN sp.commonname = 'Japanese' THEN 'JAPANESE MACAQUE'
  ELSE sp.CommonName
END as species,
s.Value as gender,
y.objectid

from IACUC_NHPYearly y
join IACUC_NHPAnimals a on (y.NHPYearlyID = a.NHPYearlyID)
join ref_ProjectsIACUC r on (r.ProjectID = y.ProjectID)
left join ref_species sp on (sp.SpeciesCode = a.Species)
left join ref_sex s on (s.Flag = a.Sex)

where (y.DateDisabled is null and a.DateDisabled is Null) and  y.CurrentYearEndDate > '12/31/2012'
and (y.ts > ? OR a.ts > ? OR r.ts > ?)
