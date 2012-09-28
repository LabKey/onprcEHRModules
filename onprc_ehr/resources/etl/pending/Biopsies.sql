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

	BiopsyId as  BiopsyId  ,
	AnimalID as Id,
	Date as Date ,
	BiopsyYear as BiopsyYear ,
	BiopsyFlag as BiopsyFlag  ,
	BiopsyCode as BiopsyCode ,


	Pathologist as Pathologist,
	rt.LastName as TechLastName1,
        rt.FirstName as TechFirstName1,
        rt.Initials as TechInitials1,
        rt.DeptCode as DepartmentInt1,
        s3.Value as Department,

	Prosector1 as Prosector1 ,
	rt2.LastName as TechLastName2,
        rt2.FirstName as TechFirstName2,
        rt2.Initials as TechInitials2,
        rt2.DeptCode as DepartmentInt2,
        s4.Value as Department2,

	Prosector2 as Prosector2 ,
	rt3.LastName as TechLastName3,
        rt3.FirstName as TechFirstName3,
        rt3.Initials as TechInitials3,
        rt3.DeptCode as DepartmentInt3,
        s5.Value as Department3,

	Prosector3 as Prosector3 ,
	rt4.LastName as TechLastName4,
        rt4.FirstName as TechFirstName4,
        rt4.Initials as TechInitials4,
        rt4.DeptCode as DepartmentInt4,
        s6.Value as Department4  ,


	pat.objectid ,
	pat.ts as rowversion


From Path_Biopsy Pat
     left join Ref_Technicians Rt on (Pat.Pathologist = Rt.ID)
     left join Sys_Parameters s3 on (s3.flag = Rt.Deptcode And s3.Field = 'Departmentcode')
     left join Ref_Technicians Rt2 on (Pat.Prosector1 = Rt2.ID)
     left join Sys_Parameters s4 on (Rt2.Deptcode = s4.Flag And s4.Field = 'DepartmentCode')
     left join  Ref_Technicians Rt3 on (Pat.Prosector2 = Rt3.ID)
     left join Sys_Parameters s5 on (Rt3.Deptcode = s5.Flag And s5.Field = 'DepartmentCode')
     left join Ref_Technicians Rt4 on (Pat.Prosector3 = Rt4.ID)
     left join Sys_Parameters s6 on (Rt4.Deptcode = s6.Flag And s6.Field = 'DepartmentCode')


