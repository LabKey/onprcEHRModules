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
Select 
	cast(AnimalID as nvarchar(4000)) as Id,
	Date as Date,


	--CauseOfDeath as CauseOfDeathInt,
    s1.Value as Cause,
    Remarks as Remark,

	case
	  WHEN rt.LastName = 'Unassigned' or rt.FirstName = 'Unassigned' THEN
        'Unassigned'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ', ' + rt.FirstName + ' (' + rt.Initials + ')'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 THEN
        rt.LastName + ', ' + rt.FirstName
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ' (' + rt.Initials + ')'
      WHEN datalength(rt.Initials) = 0 OR rt.initials = ' ' OR rt.lastname = ' none' THEN
        null
	  else
	   rt.Initials
    END as performedBy,

	--afd.DeathLocation as CageId,
	loc.Location as roomattime,
	ltrim(rtrim(row.row + convert(char(2), row.Cage))) As cageattime,

	afd.objectid
	--afd.ts as rowversion
 
From Af_Death AfD
left join Sys_Parameters s1 ON (Afd.CauseOfDeath = s1.Flag And s1.Field =  'Deathcause')
left join Ref_Location loc ON (loc.LocationId = afd.DeathLocation)
left join Ref_RowCage row on (afd.DeathLocation = row.CageID AND loc.LocationId = row.LocationID)
left join Ref_Technicians rt ON (afd.Technician = rt.ID)
left join Sys_Parameters s2 ON (s2.Field = 'DepartmentCode' And s2.Flag = rt.Deptcode)

WHERE afd.ts > ?