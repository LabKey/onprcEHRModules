/*
 * Copyright (c) 2012-2014 LabKey Corporation
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
Select					--top 1000
	--IDKey as IDKey ,
	cast(afd.AnimalID as nvarchar(4000)) as Id,
	afd.ProjectID as Project,   ---- Ref_ProjectsIacuc
	afd.StartDate as Date  ,
--	ReleaseDate as enddate ,

	coalesce(ReleaseDate, q.deathdate, q.departuredate) as enddate ,


	--afd.DietCode as DietCode,     ----- Ref_Diet
	d.Description as Diet,
	Frequency as  FrequencyInt,
	s1.value as FrequencyMeaning,
	--Duration as Duration ,		-- # of days
	Billable as Billable  ,		-- 0 = no, 1 = yes
	Status as StatusField  ,
	--BillID as  BillID,			-- not used

	afd.objectid,
	afd.ts as rowversion

From Af_Diet afd
left join Sys_Parameters s1 on (s1.Field = 'Frequency' and afd.Frequency = s1.Flag)
left join Ref_ProjectsIacuc proj on (proj.ProjectID = afd.ProjectID)
left join Ref_Diet d on (d.DietCode = afd.DietCode)
left join Af_Qrf q on (q.animalid = afd.animalid)

where afd.ts > ?
