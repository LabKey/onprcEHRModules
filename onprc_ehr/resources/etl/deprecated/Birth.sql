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
SELECT
	cast(AnimalID as nvarchar(4000)) as Id,
	Date as Date,
    s1.Value as type,
    s2.Value as cond,
	Birth_Weight As Weight,

	case
	  WHEN MotherID = 0 THEN null
	  ELSE MotherID
    END As Dam,
	case
	  WHEN FatherID = 0 THEN null
	  ELSE FatherID
    END As Sire,
	Remarks As Remark,	
	
	--TODO: add these?
	l1.Location as DeliveryLocationRoom,
	rtrim(ltrim(rtrim(r1.row) + convert(char(2), r1.Cage))) As DeliveryLocationCage,

	l2.Location as room,
	rtrim(ltrim(rtrim(r2.row) + convert(char(2), r2.Cage))) As cage,


	ConceptualAge as ConceptualAge,
	s3.Value as ConceptualAgeDeterm,
	
    --BirthType as BirthTypeInt,
    (SELECT rowid from labkey.ehr_lookups.lookups l WHERE l.set_name = 'birth_condition' AND l.value = s2.value) as birthCondition,
    --BirthCondition As BirthConditionInt,
	--ConceptualAgeDeterm as ConceptualAgeDetermInt,
	--BirthWtDescription as BirthWtDescriptionInt,
	s4.Value as BirthWtDescription,
	--DeliveryLocation As DeliveryLocationInt,
	--AssignedLocation As AssignedLocationInt,

--  --	?? As Conception,							-- what is column 'conception'


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

	--afb.ts as rowversion,
	afb.objectid

FROM Af_Birth afb 
	
left join Sys_Parameters s1 on ( s1.Field = 'BirthType' and s1.Flag = afb.BirthType) 
left join Sys_Parameters s2 on (s2.Field = 'BirthCondition' and s2.Flag = afb.BirthCondition) 
left join Sys_Parameters s3 on (s3.Field = 'ConceptualAgeDeterm' and s3.Flag = afb.ConceptualAgeDeterm) 
left join Sys_Parameters s4 on (s4.Field = 'BirthWtDescription' and s4.Flag = afb.BirthWtDescription) 
left join Ref_Technicians rt on ( afb.Technician = rt.ID) 
left join Sys_Parameters s5 on (s5.Field = 'DepartmentCode' and s5.Flag = rt.DeptCode )       
left join Ref_RowCage r1 on (r1.CageID = afb.DeliveryLocation)
left Join Ref_Location l1 on (r1.LocationID = l1.LocationId )
left join Ref_RowCage r2 on  (r2.CageID = afb.AssignedLocation)
left join Ref_Location l2 on (r2.LocationID = l2.LocationId)

where afb.ts > ?