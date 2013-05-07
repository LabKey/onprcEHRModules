/*
 * Copyright (c) 2012-2013 LabKey Corporation
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
	null as enddate,
	'Biopsy' as type,
    cast(BiopsyYear as nvarchar(4000)) + BiopsyFlag + BiopsyCode as caseno,
    null as caseid,

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
    null as procedureId,

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
	null as enddate,
	'Necropsy' as type,
	cast(PTT.PathYear as nvarchar(4000)) + PTT.PathFlag + PTT.PathCode as caseno,
    null as caseid,

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
      WHEN datalength(rt.Initials) = 0 OR rt.initials = ' ' OR rt.lastname = ' none' THEN
        null
	  else
	   rt.Initials
    END as performedBy,
    null as procedureId,

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
	(SELECT
 	    CASE
 			when (l.time = 'NULL' or l.time is null or l.time = '' or l.time = 0) then null
 			--when LEN(l.time) = 3 then convert(datetime, CONVERT(varchar(100), sg.date, 111) + ' 0' + left(l.time, 1) + ':' + RIGHT(l.time, 2))
 			when l.time = '0094' then null
 			when l.time = '2400' OR l.time = '0000' then convert(datetime, CONVERT(varchar(100), sg.date, 111) + ' ' + '00:00')
 			when LEN(l.time) = 3 then null
 			when LEN(l.time) = 4 and substring(l.time, 1, 2) < 60 then convert(datetime, CONVERT(varchar(100), sg.date, 111) + ' ' + left(l.time, 2) + ':' + RIGHT(l.time, 2))
 			else null
 		end as enddate
		FROM (select MAX(l.Time) as time FROM (
			select l.surgeryid, max(ltrim(rtrim(replace(l.time, '_', '0')))) as time
			FROM Sur_AnesthesiaLogData l
			WHERE l.time is not null AND l.time != '' AND l.Time not like '%-%' AND l.Time not like '^_%' AND l.Time != '0' AND l.Time != '00' AND l.Time != '000'
			GROUP BY l.SurgeryID) l
			WHERE l.SurgeryID = sg.SurgeryID) l
	) as enddate,
	'Surgery' as type,
	null as caseno,
    c.objectid as caseid,

	case
	  WHEN rt.LastName = 'Unassigned' or rt.FirstName = 'Unassigned' THEN
        'Unassigned'
      WHEN datalength(rt.Initials) = 0 OR rt.initials = ' ' OR rt.lastname = ' none' OR rt.lastname = 'none' THEN
        null
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ', ' + rt.FirstName + ' (' + rt.Initials + ')'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 THEN
        rt.LastName + ', ' + rt.FirstName
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ' (' + rt.Initials + ')'
	  else
	   rt.Initials
    END as performedBy,
    (SELECT rowid from labkey.ehr_lookups.procedures p WHERE p.name = r.procedureName) as procedureid,

	sg.objectid
From Sur_General sg
LEFT JOIN Ref_SurgProcedure r on (sg.procedureid = r.procedureid)
left join Ref_Technicians Rt on (sg.Surgeon = Rt.ID)
left join Sys_Parameters s3 on (s3.flag = Rt.Deptcode And s3.Field = 'Departmentcode')
left join (
	select c.AnimalID, max(ts) as ts, count(c.CaseID) as count, max(CAST(c.objectid AS varchar(36))) as objectid, c.OpenDate as date
	from af_case c
	WHERE c.GroupCode = 2
	GROUP BY c.AnimalID, c.OpenDate
) c ON (c.AnimalID = sg.AnimalID AND c.date = sg.date)

WHERE sg.ts > ? or c.ts > ?

UNION ALL

--diagnosis
Select
	cast(cln.AnimalId as varchar(4000)) as Id,
	cln.Date ,
	null as enddate,
	'Diagnosis' as type,
	null as caseno,
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
      WHEN datalength(rt.Initials) = 0 OR rt.initials = ' ' OR rt.lastname = ' none' THEN
        null
	  else
	   rt.Initials
    END as performedBy,
    null as procedureId,

	cln.objectid

FROM Cln_Dx cln
     left join  Ref_Technicians rt on (cln.Technician = rt.ID)
     left join  Sys_parameters s4 on (s4.Field = 'DepartmentCode' And s4.Flag = rt.DeptCode)
     left join Af_Case c ON (c.CaseID = cln.CaseID)

WHERE cln.ts > ?
