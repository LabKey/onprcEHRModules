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
	--PTT.AutopsyId as AutopsyId ,
	cast(PTT.AnimalID as varchar) as Id,
	PTT.Date as Date ,
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

    --TODO
	PTT.Prosector1 as Prosector1 ,
	rt2.LastName as TechLastName2,
        rt2.FirstName as TechFirstName2,
        rt2.Initials as TechInitials2,
        rt2.DeptCode as DepartmentInt2,
        s4.Value as Department2,

	PTT.Prosector2 as Prosector2 ,
	rt3.LastName as TechLastName3,
        rt3.FirstName as TechFirstName3,
        rt3.Initials as TechInitials3,
        rt3.DeptCode as DepartmentInt3,
        s5.Value as Department3,

	PTT.Prosector3 as Prosector3 ,
	rt4.LastName as TechLastName4,
        rt4.FirstName as TechFirstName4,
        rt4.Initials as TechInitials4,
        rt4.DeptCode as DepartmentInt4,
        s6.Value as Department4,

	--NOTE: this is basically QCState
	PTT.Status as StatusInt,
        s2.value as NecropsyStatus,

	PTT.CauseOfDeath as CauseOfDeathInt ,
        s1.value as CauseofDeath,

	PTT.objectid,
	PTT.ts as rowversion

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