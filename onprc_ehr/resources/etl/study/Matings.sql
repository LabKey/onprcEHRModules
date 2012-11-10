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
	Date as Date  ,
	MaleId as Male,

	--TODO
	--MatingType as MatingTypeInt  ,
	s1.Value as MatingType,

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

	--IDKey as IDKey,
	bm.ts as rowversion,
	bm.objectid AS objectid

FROM Brd_Matings bm
left join Sys_parameters s1 ON (s1.Field = 'MatingType' and s1.Flag = MatingType)
left join Ref_Technicians rt ON (bm.Technician = rt.ID)
left join Sys_parameters s2 On (s2.Field = 'DepartmentCode' and s2.Flag = rt.DeptCode)

where bm.ts > ?