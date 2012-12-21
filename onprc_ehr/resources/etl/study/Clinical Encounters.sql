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
    cast(AnimalID as nvarchar(4000)) as Id,
	Date,
	'Biopsy' as type,
    cast(BiopsyYear as nvarchar(4000)) + BiopsyFlag + BiopsyCode as caseno,

	case
	  WHEN rt.LastName = 'Unassigned' or rt.FirstName = 'Unassigned' THEN
        'Unassigned'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ', ' + rt.FirstName + ' (' + rt.Initials + ')'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 THEN
        rt.LastName + ', ' + rt.FirstName
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ' (' + rt.Initials + ')'
	  else
	   rt.Initials
    END as performedBy,

	pat.objectid 

From Path_Biopsy Pat
     left join Ref_Technicians Rt on (Pat.Pathologist = Rt.ID)
     left join Sys_Parameters s3 on (s3.flag = Rt.Deptcode And s3.Field = 'Departmentcode')
     left join Ref_Technicians Rt2 on (Pat.Prosector1 = Rt2.ID)
     left join Sys_Parameters s4 on (Rt2.Deptcode = s4.Flag And s4.Field = 'DepartmentCode')
     left join  Ref_Technicians Rt3 on (Pat.Prosector2 = Rt3.ID)
     left join Sys_Parameters s5 on (Rt3.Deptcode = s5.Flag And s5.Field = 'DepartmentCode')
     left join Ref_Technicians Rt4 on (Pat.Prosector3 = Rt4.ID)
     left join Sys_Parameters s6 on (Rt4.Deptcode = s6.Flag And s6.Field = 'DepartmentCode')

WHERE Pat.ts > ?

UNION ALL

Select
	cast(PTT.AnimalID as nvarchar(4000)) as Id,
	PTT.Date as Date ,
	'Necropsy' as type,
	cast(PTT.PathYear as nvarchar(4000)) + PTT.PathFlag + PTT.PathCode as caseno,

    --the pathologist
	case
	  WHEN rt.LastName = 'Unassigned' or rt.FirstName = 'Unassigned' THEN
        'Unassigned'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ', ' + rt.FirstName + ' (' + rt.Initials + ')'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 THEN
        rt.LastName + ', ' + rt.FirstName
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ' (' + rt.Initials + ')'
	  else
	   rt.Initials
    END as performedBy,

	PTT.objectid

From Path_Autopsy PTT
left join Sys_Parameters s1 on (PTT.CauseofDeath = s1.flag And s1.Field = 'Deathcause')
left join Sys_Parameters s2 on (PTT.Status = s2.flag And s2.field = 'AutopsyStatus')
left join Ref_Technicians Rt on (PTT.Pathologist = Rt.ID)
left join Sys_Parameters s3 on (s3.flag = Rt.Deptcode And s3.Field = 'Departmentcode')
left join Ref_Technicians Rt2 on (PTT.Prosector1 = Rt2.ID)
left join Sys_Parameters s4 on (Rt2.Deptcode = s4.Flag And s4.Field = 'DepartmentCode')
left join Ref_Technicians Rt3 on (PTT.Prosector2 = Rt3.ID)
left join Sys_Parameters s5 on (Rt3.Deptcode = s5.Flag And s5.Field = 'DepartmentCode')
left join Ref_Technicians Rt4 on (PTT.Prosector3 = Rt4.ID)
left join Sys_Parameters s6 on (Rt4.Deptcode = s6.Flag And s6.Field = 'DepartmentCode')
WHERE ptt.ts > ?

UNION ALL

--surgeries
Select
	cast(sg.AnimalID as nvarchar(4000)) as Id,
	sg.Date as Date ,
	'Surgery' as type,
	null as caseno,

	case
	  WHEN rt.LastName = 'Unassigned' or rt.FirstName = 'Unassigned' THEN
        'Unassigned'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ', ' + rt.FirstName + ' (' + rt.Initials + ')'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 THEN
        rt.LastName + ', ' + rt.FirstName
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ' (' + rt.Initials + ')'
	  else
	   rt.Initials
    END as performedBy,

	sg.objectid

From Sur_General sg
left join Ref_Technicians Rt on (sg.Surgeon = Rt.ID)
left join Sys_Parameters s3 on (s3.flag = Rt.Deptcode And s3.Field = 'Departmentcode')

WHERE sg.ts > ?

UNION ALL

--diagnosis
Select
	cast(cln.AnimalId as varchar(4000)) as Id,
	cln.Date ,
	'Diagnosis' as type,
	c.objectid as caseId,
	case
	  WHEN rt.LastName = 'Unassigned' or rt.FirstName = 'Unassigned' THEN
        'Unassigned'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ', ' + rt.FirstName + ' (' + rt.Initials + ')'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 THEN
        rt.LastName + ', ' + rt.FirstName
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ' (' + rt.Initials + ')'
	  else
	   rt.Initials
    END as performedBy,

	cln.objectid

FROM Cln_Dx cln
     left join  Ref_Technicians rt on (cln.Technician = rt.ID)
     left join  Sys_parameters s4 on (s4.Field = 'DepartmentCode' And s4.Flag = rt.DeptCode)
     left join Af_Case c ON (c.CaseID = cln.CaseID)

WHERE cln.ts > ?
