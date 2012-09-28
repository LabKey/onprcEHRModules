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
SELECT
	cast(AnimalID as varchar) as Id,
	Date as Date,
	'Menses' as category,
	--Technician As TechnicianID,
	--LastName as TechLastName,
	--FirstName as TechFirstName,
	--Initials as TechInitials,
	--DeptCode as DepartmentCodeInt,
	--s1.Value as DepartmentCode,
	--IDKey As IDKey,
    bm.ts as rowversion,
    bm.objectid

FROM Brd_Menstruations bm

LEFT JOIN Ref_Technicians rt ON (bm.Technician = rt.ID)
LEFT JOIN Sys_parameters s1 ON (s1.Field = 'DepartmentCode' and s1.Flag = rt.DeptCode)

where bm.ts > ?