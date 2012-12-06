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
	Date,
	'Biopsy' as type,
    cast(BiopsyYear as varchar) + BiopsyFlag + BiopsyCode as caseno,

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

	pat.objectid ,
	l.logtext as remark



From Path_Biopsy Pat
     left join Ref_Technicians Rt on (Pat.Pathologist = Rt.ID)
     left join Sys_Parameters s3 on (s3.flag = Rt.Deptcode And s3.Field = 'Departmentcode')
     left join Ref_Technicians Rt2 on (Pat.Prosector1 = Rt2.ID)
     left join Sys_Parameters s4 on (Rt2.Deptcode = s4.Flag And s4.Field = 'DepartmentCode')
     left join  Ref_Technicians Rt3 on (Pat.Prosector2 = Rt3.ID)
     left join Sys_Parameters s5 on (Rt3.Deptcode = s5.Flag And s5.Field = 'DepartmentCode')
     left join Ref_Technicians Rt4 on (Pat.Prosector3 = Rt4.ID)
     left join Sys_Parameters s6 on (Rt4.Deptcode = s6.Flag And s6.Field = 'DepartmentCode')

left join Path_BiopsyLog l ON (l.BiopsyID = Pat.BiopsyId AND len(l.LogText) > 0 AND l.LogText != '' and l.LogText not like 'Testing testing testing%')

WHERE Pat.ts > ?

UNION ALL

Select
	cast(PTT.AnimalID as varchar) as Id,
	PTT.Date as Date ,
	'Necropsy' as type,
	cast(PTT.PathYear as varchar) + PTT.PathFlag + PTT.PathCode as caseno,

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

	PTT.objectid,
	l.logtext as remark

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

left join Path_AutopsyLog l ON (l.AutopsyID = ptt.AutopsyId AND len(l.LogText) > 0 AND l.LogText != '' and l.LogText not like 'Testing testing testing%')
WHERE ptt.ts > ?


--surgeries

