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
	--RemarksID as RemarksID ,
	cast(afr.AnimalID as nvarchar(4000)) as Id,
	RemarksDate as date,
	coalesce(afr.datedisabled, q.deathdate, q.departuredate) as enddate,

	--Afr.Topic as TopicInt  ,
	s1.value as Category,
	Remarks as value,

    --TODO
	--ActionDate as ActionDate ,
	--afr.PoolCode as PoolCode ,        ----- Ref_Pool
	--rp.ShortDescription,
	--rp.Description,
	--afr.DateCreated as DateCreated ,
	--afr.DateDisabled as DateDisabled,

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

    afr.objectid
	--afr.ts as rowversion

From Af_Remarks Afr
left join Sys_Parameters s1 on (Afr.Topic = s1.Flag And s1.Field = 'Remarks Topic')
left join Sys_Parameters s2 on (s2.Field = 'DepartmentCode' And Afr.Department = s2.flag)
left join Ref_Technicians Rt on (Afr.TechnicianID = Rt.ID)
left join Sys_Parameters s3 on (s3.flag = Rt.Deptcode And s3.Field = 'DepartmentCode')
left join Ref_pool rp on (rp.PoolCode = afr.PoolCode)
left join Af_Qrf q on (q.animalid = afr.animalid)

WHERE (afr.ts > ?)
