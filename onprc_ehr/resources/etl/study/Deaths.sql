/*
 * Copyright (c) 2012 LabKey Corporation
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
	cast(AnimalID as varchar) as Id,
	Date as Date,
	--WeightAtDeath as WeightAtDeath,
	--CauseOfDeath as CauseOfDeathInt,
    s1.Value as Cause,
    Remarks as Remark,
  
	Technician as TechnicianInt ,      ----- Ref_Technicians
	rt.LastName as TechLastName,
    rt.FirstName as TechFirstName,
    rt.Initials as TechInitials,
    rt.DeptCode as DepartmentInt,
    s2.Value as Department,
	
	afd.DeathLocation as CageId,
	loc.Location as DeathLocation,
	row.row + '-' + convert(char(2), row.Cage) As DeathCage,

	afd.objectid,
	afd.ts as rowversion
 
From Af_Death AfD
left join Sys_Parameters s1 ON (Afd.CauseOfDeath = s1.Flag And s1.Field =  'Deathcause')
left join Ref_Location loc ON (loc.LocationId = afd.DeathLocation)
left join Ref_RowCage row on (afd.DeathLocation = row.CageID AND loc.LocationId = row.LocationID)
left join Ref_Technicians Rt ON (afd.Technician = rt.ID)
left join Sys_Parameters s2 ON (s2.Field = 'DepartmentCode' And s2.Flag = Rt.Deptcode)

WHERE afd.ts > ?