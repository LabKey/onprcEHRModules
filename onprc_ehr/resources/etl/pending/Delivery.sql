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
	MotherID  ,
	Date,

	DeliveryType as DeliveryTypeInt ,
    s1.Value as DeliveryType,

	InfantID as Id,
	FatherID ,
	NaturalMother,
	MultipleBirthsFlag ,

	Technician as TechnicianInt ,
	rt.LastName as TechLastName,
    rt.FirstName as TechFirstName,
    rt.Initials as TechInitials,
    rt.DeptCode as DepartmentInt,

    s2.value as Department,
	Remarks ,
	IDKey,

	afd.objectid,
	afd.ts as rowversion

From Af_Delivery AfD
left join Sys_Parameters s1 on (Afd.DeliveryType = s1.Flag And s1.Field = 'DeliveryMode')
left join Ref_Technicians Rt on ( Rt.ID = AfD.Technician )
left join Sys_Parameters s2 on ( s2.field = 'Departmentcode'   And rt.Deptcode = s2.flag  )