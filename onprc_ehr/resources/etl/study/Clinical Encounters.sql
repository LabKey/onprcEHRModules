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

-- Select
--     cast(AnimalID as nvarchar(4000)) as Id,
-- 	Date,
-- 	null as enddate,
-- 	'Biopsy' as type,
--     cast(BiopsyYear as nvarchar(4000)) + BiopsyFlag + BiopsyCode as caseno,
--     null as caseid,
--
-- 	case
-- 	  WHEN rt.LastName = 'Unassigned' or rt.FirstName = 'Unassigned' THEN
--         'Unassigned'
-- 	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 AND datalength(rt.Initials) > 0 THEN
--         rt.LastName + ', ' + rt.FirstName + ' (' + rt.Initials + ')'
-- 	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 THEN
--         rt.LastName + ', ' + rt.FirstName
-- 	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.Initials) > 0 THEN
--         rt.LastName + ' (' + rt.Initials + ')'
--       WHEN datalength(rt.Initials) = 0 OR rt.initials = ' ' OR rt.lastname = ' none' THEN
--         null
-- 	  else
-- 	   rt.Initials
--     END as performedBy,
--     null as procedureId,
--
-- 	CAST(pat.objectid as varchar(38)) as objectid,
--     null as chargetype,
--   null as project,
--   null as remark
--
-- From Path_Biopsy Pat
--      left join Ref_Technicians Rt on (Pat.Pathologist = Rt.ID)
--      left join Sys_Parameters s3 on (s3.flag = Rt.Deptcode And s3.Field = 'Departmentcode')
--      left join Ref_Technicians Rt2 on (Pat.Prosector1 = Rt2.ID)
--      left join Sys_Parameters s4 on (Rt2.Deptcode = s4.Flag And s4.Field = 'DepartmentCode')
--      left join  Ref_Technicians Rt3 on (Pat.Prosector2 = Rt3.ID)
--      left join Sys_Parameters s5 on (Rt3.Deptcode = s5.Flag And s5.Field = 'DepartmentCode')
--      left join Ref_Technicians Rt4 on (Pat.Prosector3 = Rt4.ID)
--      left join Sys_Parameters s6 on (Rt4.Deptcode = s6.Flag And s6.Field = 'DepartmentCode')
--
-- WHERE Pat.ts > ?
--
-- UNION ALL

-- Select
-- 	cast(PTT.AnimalID as nvarchar(4000)) as Id,
-- 	PTT.Date as Date ,
-- 	null as enddate,
-- 	'Necropsy' as type,
-- 	cast(PTT.PathYear as nvarchar(4000)) + PTT.PathFlag + PTT.PathCode as caseno,
--     null as caseid,
--
--     --the pathologist
-- 	case
-- 	  WHEN rt.LastName = 'Unassigned' or rt.FirstName = 'Unassigned' THEN
--         'Unassigned'
-- 	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 AND datalength(rt.Initials) > 0 THEN
--         rt.LastName + ', ' + rt.FirstName + ' (' + rt.Initials + ')'
-- 	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 THEN
--         rt.LastName + ', ' + rt.FirstName
-- 	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.Initials) > 0 THEN
--         rt.LastName + ' (' + rt.Initials + ')'
--       WHEN datalength(rt.Initials) = 0 OR rt.initials = ' ' OR rt.lastname = ' none' THEN
--         null
-- 	  else
-- 	   rt.Initials
--     END as performedBy,
--     null as procedureId,
--
-- 	CAST(PTT.objectid as varchar(38)) as objectid,
--     null as chargetype,
--     null as project,
--     null as remark
--
-- From Path_Autopsy PTT
-- left join Sys_Parameters s1 on (PTT.CauseofDeath = s1.flag And s1.Field = 'Deathcause')
-- left join Sys_Parameters s2 on (PTT.Status = s2.flag And s2.field = 'AutopsyStatus')
-- left join Ref_Technicians Rt on (PTT.Pathologist = Rt.ID)
-- left join Sys_Parameters s3 on (s3.flag = Rt.Deptcode And s3.Field = 'Departmentcode')
-- left join Ref_Technicians Rt2 on (PTT.Prosector1 = Rt2.ID)
-- left join Sys_Parameters s4 on (Rt2.Deptcode = s4.Flag And s4.Field = 'DepartmentCode')
-- left join Ref_Technicians Rt3 on (PTT.Prosector2 = Rt3.ID)
-- left join Sys_Parameters s5 on (Rt3.Deptcode = s5.Flag And s5.Field = 'DepartmentCode')
-- left join Ref_Technicians Rt4 on (PTT.Prosector3 = Rt4.ID)
-- left join Sys_Parameters s6 on (Rt4.Deptcode = s6.Flag And s6.Field = 'DepartmentCode')
-- WHERE ptt.ts > ?
--
-- UNION ALL

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
    (SELECT rowid from labkey.ehr_lookups.procedures p WHERE p.category = 'Surgery' AND p.name = r.procedureName) as procedureid,

  cast(sg.objectid as varchar(38)) as objectid,
  CASE
    WHEN s4.value = 'Surgery Staff' THEN 'DCM: Surgery Services'
    WHEN s4.value = 'No Surgery Staff' THEN 'Research Staff'
    WHEN s4.value = 'No Charge' THEN 'No Charge'
    ELSE ('ERROR: ' + s4.value)
  END as chargetype,
  coalesce(ibs.projectId, afc.project) as project,
  null as remark

From Sur_General sg
LEFT JOIN Ref_SurgProcedure r on (sg.procedureid = r.procedureid)
left join Ref_Technicians Rt on (sg.Surgeon = Rt.ID)
left join Sys_Parameters s3 on (s3.flag = Rt.Deptcode And s3.Field = 'Departmentcode')
left join Sys_Parameters s4 on (s4.flag = sg.ChargeCode And s4.Field = 'SurgeryChargeCode')
left join (
	select c.AnimalID, max(ts) as ts, count(c.CaseID) as count, max(CAST(c.objectid AS varchar(36))) as objectid, c.OpenDate as date
	from af_case c
	WHERE c.GroupCode = 2
	GROUP BY c.AnimalID, c.OpenDate
) c ON (c.AnimalID = sg.AnimalID AND c.date = sg.date)

LEFT JOIN (
Select
  t1.surgeryId,
  max(ibs2.ProjectID) as projectId,
  max(ibs2.ts) as ts
from (
   SELECT
     sg1.SurgeryID,
     MAX(sg1.AnimalID) as AnimalID,
     MAX(sg1.date) as date,
     MAX(sg1.procedureId) as procedureId,
     max(ibs1.InvoiceNumber) as maxNumber
     From Sur_General sg1
     left join AF_ChargesIBS ibs1 on (convert(varchar(10),sg1.AnimalID) = ibs1.TransactionDescription and sg1.Date = ibs1.TransactionDate and convert(varchar(10), sg1.ProcedureID) = ibs1.ItemCode)
     group by sg1.SurgeryID
  ) t1
  left join AF_ChargesIBS ibs2 on (t1.maxNumber = ibs2.InvoiceNumber And convert(varchar(10),t1.AnimalID) = ibs2.TransactionDescription and t1.Date = ibs2.TransactionDate and convert(varchar(10), t1.ProcedureID) = ibs2.ItemCode)
  group by t1.SurgeryID
) ibs ON (ibs.surgeryId = sg.surgeryId)

LEFT JOIN (
  SELECT
    sg1.SurgeryID,
    MAX(sg1.AnimalID) as AnimalID,
    max(afc.ts) as maxTs,
    --MAX(sg1.date) as date,
    --MAX(sg1.procedureId) as procedureId,
    max(afc.ProjectID) as project
    --COUNT(distinct afc.projectID) as total

  From Sur_General sg1
    left join AF_Charges afc on (sg1.AnimalID = afc.AnimalID and sg1.Date = afc.ChargeDate and sg1.ProcedureID = afc.ProcedureID)
  group by sg1.SurgeryID
) afc ON (afc.surgeryId = sg.surgeryId)

WHERE (sg.ts > ? or c.ts > ? or ibs.ts > ? or afc.maxTs > ?)

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

  cast(cln.objectid as varchar(38)) as objectid,
  null as chargetype,
  null as project,
  null as remark

FROM Cln_Dx cln
     left join  Ref_Technicians rt on (cln.Technician = rt.ID)
     left join  Sys_parameters s4 on (s4.Field = 'DepartmentCode' And s4.Flag = rt.DeptCode)
     left join Af_Case c ON (c.CaseID = cln.CaseID)

WHERE cln.ts > ?

UNION ALL

--implant procedures
Select
  cast(cln.AnimalId as varchar(4000)) as Id,
  cln.Date ,
  null as enddate,
  'Surgery' as type,
  null as caseno,
  NULL as caseId,

  max(case
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
  END) as performedBy,
  (select rowid from labkey.ehr_lookups.procedures WHERE name = 'Hormone Implant/Removal' and active = 1) as procedureId,

  max(cast(cln.objectid as varchar(36))) as objectid,
  CASE
    WHEN max(s5.Value) = 'Surgery Staff' THEN 'DCM: Surgery Services'
    WHEN max(s5.Value) = 'No Surgery Staff' THEN 'Research Staff'
    WHEN max(s5.Value) = 'No Charge' THEN 'No Charge'
    ELSE ('ERROR: ' + max(s4.value))
  END as chargetype,
  max(proj.ProjectId) as project,
  null as remark  --note: remark being entered into encounter_summaries

FROM sur_implants cln
  left join  Ref_Technicians rt on (cln.Surgeon = rt.ID)
  LEFT JOIN Sys_parameters s1 ON (s1.Field = 'ImplantSize' AND s1.Flag = cln.size)
  LEFT JOIN Sys_parameters s2 ON (s2.Field = 'ImplantType' AND s2.Flag = cln.type)
  LEFT JOIN Sys_parameters s3 ON (s3.Field = 'ImplantSite' AND s3.Flag = cln.site)
  LEFT JOIN Sys_parameters s4 ON (s4.Field = 'ImplantAction' AND s4.Flag = cln.action)
  LEFT JOIN Sys_parameters s5 ON (s5.Field = 'SurgeryChargeCode' AND s5.Flag = cln.chargecode)

  left join  Sys_parameters s6 on (s6.Field = 'DepartmentCode' And s6.Flag = rt.DeptCode)
  LEFT JOIN (
    SELECT
    i.IDKey,
    --a.AnimalID,
    --a.ChargeDate,
    max(a.ProjectID) as ProjectID,
    max(a.ts) as maxChargeTs

    FROM Sur_Implants i
    left join Af_Charges a ON (i.AnimalID = a.AnimalID AND i.Date = a.ChargeDate)
    left join Ref_FeesSurgical fs on (a.ProcedureID = fs.ProcedureID and fs.DateDisabled is null)
    left join Ref_SurgProcedure r on (fs.ProcedureID = r.ProcedureID)
    where r.ProcedureName like '%Hormone%' and a.AccountNo is null
    and a.ChargeDate > '2013-10-01'
    GROUP BY i.IdKey
  ) proj ON (cln.IdKey = proj.IdKey)

GROUP BY cln.AnimalID, cln.Date
HAVING (MAX(cln.ts) > ? OR max(proj.maxChargeTs) > ?)

UNION ALL

SELECT
  cast(dx.AnimalID as nvarchar(4000)) as Id,
  dx.date,
  null as enddate,
  'Procedure' as type,
  null as caseno,
  null as caseid,
  null as performedBy,
  (SELECT rowid FROM labkey.ehr_lookups.procedures WHERE category = 'Procedure' AND name = CASE
    WHEN s2.value = 'F-79020' THEN 'Aspiration gastric contents'
    WHEN s2.value = 'P-YY841' THEN 'Bottle feed'
    WHEN s2.value = 'P-Y3060' THEN 'Cage change'
    WHEN s2.value = 'P-1210C' THEN 'Chorio-Decidual Infusion'
    WHEN s2.value = 'F-Y0215' THEN 'Collar Check'
    WHEN s2.value = 'F-Y0225' THEN 'Collar Placement'
    WHEN s2.value = 'F-Y0220' THEN 'Collar Rmvl'
    WHEN s2.value = 'P-X1550' THEN 'CT Scan'
    WHEN s2.value = 'P-X7200' THEN 'DEXA Scan'
    WHEN s2.value = 'P-17800' THEN 'Dressing, apply'
    WHEN s2.value = 'P-X0820' THEN 'Dx Rads Bilateral INJ, w/Cont Media'
    WHEN s2.value = 'P-X1000' THEN 'Dx Rads INJ w/Cont Media'
    WHEN s2.value = 'P-X0650' THEN 'Dx Rads PO w/Cont Media'
    WHEN s2.value = 'P-X0900' THEN 'Dx Rads Positive INJ, w/Cont Media'
    WHEN s2.value = 'P-YY500' THEN 'Dye marking'
    WHEN s2.value = 'P-95700' THEN 'Ejaculation'
    WHEN s2.value = 'P-40370' THEN 'Glucose Tolerance Test'
    WHEN s2.value = 'P-yy780' THEN 'HbA1C test'
    WHEN s2.value = 'P-Y3230' THEN 'Heelstick lancet'
    WHEN s2.value = 'P-X9770' THEN 'ID monitor of fetus'
    WHEN s2.value = 'P-40375' THEN 'Insulin Tolerance Test'
    WHEN s2.value = 'P-X9770' THEN 'Intrapartum Doppler monitor of fetus'
    WHEN s2.value = 'P-12550' THEN 'Intubation'
    WHEN s2.value = 'P-1920X' THEN 'Jacket, Apply'
    WHEN s2.value = 'P-1927X' THEN 'Jacket, Maintain'
    WHEN s2.value = 'P-1924X' THEN 'Jacket, Remove'
    WHEN s2.value = 'P-71630' THEN 'Monitoring Temperature'
    WHEN s2.value = 'p-x5200' THEN 'MRI'
    WHEN s2.value = 'P-YY838' THEN 'Nasal (only) swab'
    WHEN s2.value = 'P-YY843' THEN 'Nasal gastric swab'
    WHEN s2.value = 'P-YY835' THEN 'Nasal/gastric gavage'
    WHEN s2.value = 'P-02360' THEN 'Palpation'
    WHEN s2.value = 'P-02400' THEN 'Palpation, bimanual'
    WHEN s2.value = 'P-00110' THEN 'Procedure for Staff Training'
    WHEN s2.value = 'P-10850' THEN 'Puncture & Drainage'
    WHEN s2.value = 'P-Y3192' THEN 'Remove animal appendage from cage'
    WHEN s2.value = '' THEN 'Sedation'
    WHEN s2.value = 'P-Y3130' THEN 'Sex determination'
    WHEN s2.value = 'P-2037X' THEN 'Spec Clltn: Urine cystocentesis'
    WHEN s2.value = 'P-1926x' THEN 'Swivel-Tether change'
    WHEN s2.value = 'P-12090' THEN 'Tattoo'
    WHEN s2.value = 'P-Y3100' THEN 'Transporting'
    WHEN s2.value = 'P-X9751' THEN 'Ultrasonic guidance of amniocentesis'
    WHEN s2.value = 'P-X9750' THEN 'Ultrasound'
    WHEN s2.value = 'P-2035X' THEN 'Vag Swab Cltn(by Lab)'
    WHEN s2.value = 'P-YY787' THEN 'Vag tampon insertion, initial'
    WHEN s2.value = 'P-YY790' THEN 'Vaginal ring, insertion'
    WHEN s2.value = 'P-YY791' THEN 'Vaginal ring, removal'
    WHEN s2.value = 'P-YY789' THEN 'Vaginal tampon, final removal'
    WHEN s2.value = 'P-YY788' THEN 'Vaginal tampon, maintenance'
    WHEN s2.value = 'P-Y3110' THEN 'Worming'
    WHEN s2.value = 'P-02314' THEN 'Physical Exam Complete'  --annual exam
    WHEN s2.value = 'P-02310' THEN 'Physical Exam Complete'  --PE complete
  END) as procedureId,

  cast(s.objectid as varchar(38)) + '-' + cast(s2.i as varchar(100)) + '-' + cast(s2.value as nvarchar(100)) as objectid,
  null as chargetype,
  null as project,
  null as remark

FROM Cln_DxSnomed s
  left join cln_dx dx ON (dx.DiagnosisID = s.DiagnosisID)
  left join af_case c ON (dx.caseid = c.caseid)
  cross apply dbo.fn_splitter(s.snomed, ',') s2
where s2.value is not null and s2.value IN (
  'F-79020',
  'P-YY841',
  'P-Y3060',
  'P-1210C',
  'F-Y0215',
  'F-Y0225',
  'F-Y0220',
  'P-X1550',
  'P-X7200',
  'P-17800',
  'P-X0820',
  'P-X1000',
  'P-X0650',
  'P-X0900',
  'P-YY500',
  'P-95700',
  'P-40370',
  'P-yy780',
  'P-Y3230',
  'P-X9770',
  'P-40375',
  'P-X9770',
  'P-12550',
  'P-1920X',
  'P-1927X',
  'P-1924X',
  'P-71630',
  'p-x5200',
  'P-YY838',
  'P-YY843',
  'P-YY835',
  'P-02360',
  'P-02400',
  'P-00110',
  'P-10850',
  'P-Y3192',
  'P-Y3130',
  'P-2037X',
  'P-1926x',
  'P-12090',
  'P-Y3100',
  'P-X9751',
  'P-X9750',
  'P-2035X',
  'P-YY787',
  'P-YY790',
  'P-YY791',
  'P-YY789',
  'P-YY788',
  'P-Y3110',
  'P-02314',
  'P-02310'
)
and s.ts > ?

--add TB tests
UNION ALL

SELECT
  cast(w.AnimalID as nvarchar(4000)) as Id,
  w.date,
  null as enddate,
  'Procedure' as type,
  null as caseno,
  null as caseid,
  null as performedBy,
  (SELECT rowid FROM labkey.ehr_lookups.procedures WHERE category = 'Procedure' AND name = 'TB Test Intradermal') as procedureid,
  (cast(w.objectid as varchar(38)) + '_tb') as objectid,
  null as chargetype,
  null as project,
  null as remark

FROM af_weights w
where w.tbflag = 1 and w.ts > ?

UNION ALL

SELECT
  cast(dx.AnimalID as nvarchar(4000)) as Id,
  dx.date,
  null as enddate,
  'Procedure' as type,
  null as caseno,
  null as caseid,
  null as performedBy,
  (SELECT rowid FROM labkey.ehr_lookups.procedures WHERE category = 'Procedure' AND name = 'TB Test Intradermal') as procedureid,
  cast(sno.objectid as varchar(36)) as objectid,
  null as chargetype,
  null as project,
  null as remark

FROM Cln_DXSnomed sno
  LEFT JOIN Cln_DX dx ON (sno.DiagnosisID = dx.DiagnosisID)
  LEFT JOIN af_weights w2 ON (w2.AnimalId = dx.AnimalID AND w2.Date = dx.Date and w2.TBFlag = 1)

WHERE sno.Snomed = 'P-54268' AND w2.AnimalId IS NULL and sno.ts > ?