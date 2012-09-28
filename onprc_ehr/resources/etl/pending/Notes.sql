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
	RemarksID as RemarksID ,
	cast(AnimalID as varchar) as Id,
	RemarksDate as RemarksDate ,
	--TechnicianID as TechnicianID ,
	--rt.LastName as TechLastName,
    --    rt.FirstName as TechFirstName,
    --    rt.Initials as TechInitials,
    --    rt.DeptCode as TechDepartmentInt,
    --    s3.value as TechDepartment,
	--Afr.Department as DepartmentInt ,
	--s2.Value as Department,
	Afr.Topic as TopicInt  ,
	s1.value as Topic,
	Remarks as Remarks ,
	ActionDate as ActionDate ,
	afr.PoolCode as PoolCode ,        ----- Ref_Pool
	rp.ShortDescription,
	rp.Description,
	afr.DateCreated as DateCreated ,
	afr.DateDisabled as DateDisabled,


	afr.objectid,
	afr.ts as rowversion

From Af_Remarks Afr
left join Sys_Parameters s1 on (Afr.Topic = s1.Flag And s1.Field = 'Remarks Topic')
left join Sys_Parameters s2 on (s2.Field = 'DepartmentCode' And Afr.Department = s2.flag)
left join Ref_Technicians Rt on (Afr.TechnicianID = Rt.ID)
left join Sys_Parameters s3 on (s3.flag = Rt.Deptcode And s3.Field = 'DepartmentCode')
left join Ref_pool rp on (rp.PoolCode = afr.PoolCode)