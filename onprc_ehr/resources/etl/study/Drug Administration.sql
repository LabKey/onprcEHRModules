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
-- SELECT
--   d.*,
--   --add in projects
--   coalesce(
--       (SELECT CASE WHEN count(projectId) = 1 THEN max(projectId) ELSE null END as project FROM Af_ChargesIBS ibs WHERE ibs.IDKey = d.IDKey),
--       (SELECT CASE WHEN count(projectId) = 1 THEN max(projectId) ELSE null END as project FROM AF_Assignments a WHERE a.animalid = d.animalid AND (d.date >= a.AssignDate AND d.Date <= a.ReleaseDate))
--   ) as project,
--
--   coalesce(
--       (SELECT max(ts) as ts FROM Af_ChargesIBS ibs WHERE ibs.IDKey = d.IDKey),
--       (SELECT max(ts) as ts FROM AF_Assignments a WHERE a.animalid = d.animalid AND (d.date >= a.AssignDate AND d.Date <= a.ReleaseDate))
--   ) as projectTs
--
-- FROM (

-- -- TODO: deprecate?
-- SELECT * FROM (
-- SELECT
--   t.Id,
--   DATEADD (DAY , i.value, t.date) as date,
--   t.treatmentStartDate,
--   t.enddate as treatmentEndDate,
-- --t.duration,
-- --i.value,
--   t.code,
--   t.meaning,
--   t.remark,
--   t.amount,
--   t.amount_units,
--   t.route,
--   (cast(t.objectid as varchar(38)) + '_' + convert(varchar, t.date, 120)) as objectid,
--   t.parentId,
--   t.treatmentId,
--   CASE WHEN t.treatmentid IS NULL THEN NULL ELSE DATEADD(DAY , i.value, t.date) END as timeordered,
--   t.performedBy,
--   t.category,
--   null as caseid
--
-- FROM (
--    SELECT
--      t1.*,
--      CASE
--        WHEN t1.enddate2 is null THEN t1.alternateEnd
--        WHEN t1.alternateEnd is null then t1.enddate2
--        WHEN t1.alternateEnd < t1.enddate2 THEN t1.alternateEnd
--        ELSE t1.enddate2
--      END as enddate,
--      CASE
--       WHEN (t1.enddate2 is null AND t1.alternateEnd is null) THEN null
--       WHEN t1.enddate2 is null THEN DateDiff(d, cast(t1.date as date), cast(t1.alternateEnd as date))
--       WHEN t1.alternateEnd is null then DateDiff(d, cast(t1.date as date), cast(t1.enddate2 as date))
--       WHEN t1.alternateEnd < t1.enddate2 THEN DateDiff(d, cast(t1.date as date), cast(t1.alternateEnd as date))
--       ELSE DateDiff(d, t1.date, t1.enddate2)
--      END + 1 as duration
-- FROM (
-- SELECT
--   CASE
--     WHEN enddate IS NULL THEN cast(DATEADD(minute, -1, DATEADD(day, 1+CASE WHEN duration = 0 THEN 1 ELSE duration END, cast(cast(date as date) AS datetime))) as datetime)
--     ELSE coalesce(EndDate, q.deathdate, q.departuredate)
--   END as enddate2,
--   coalesce(q.deathdate, q.departuredate) as alternateEnd,
--
--   cast(m.AnimalId as nvarchar(4000)) as Id,
--   m.date AS treatmentStartDate,
--
--   case
--   when cln.MedicationTime is null or cln.MedicationTime = '' or LEN(medicationtime) = 0 then m.date
--   when LEN(medicationtime) = 3 then convert(datetime, CONVERT(varchar(100), m.date, 111) + ' 0' + left(cln.MedicationTime, 1) + ':' + RIGHT(cln.medicationtime, 2))
--   else convert(datetime, CONVERT(varchar(100), m.date, 111) + ' ' + left(cln.MedicationTime, 2) + ':' + RIGHT(cln.medicationtime, 2))
--   end as date,
--
--   Medication as code,
--   sno.Description as meaning,
--
--   null as remark,
--   Dose as amount,
--   CASE
--     WHEN s6.value = 'Surgery' THEN 'Surgical'
--     WHEN ss.code is not null THEN 'Diet'
--     ELSE 'Clinical'
--   END as category,
--
--   s2.Value as amount_units,
--   s3.Value as route,
--   cast(coalesce(cln.objectid, m.objectid) as varchar(38)) as objectid,
--   null as parentId,
--   m.objectId as treatmentId,
--
--   case
--   WHEN rt.LastName = 'Unassigned' or rt.FirstName = 'Unassigned' THEN
--     'Unassigned'
--   WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 AND datalength(rt.Initials) > 0 THEN
--     rt.LastName + ', ' + rt.FirstName + ' (' + rt.Initials + ')'
--   WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 THEN
--     rt.LastName + ', ' + rt.FirstName
--   WHEN datalength(LastName) > 0 AND datalength(rt.Initials) > 0 THEN
--     rt.LastName + ' (' + rt.Initials + ')'
--   WHEN datalength(rt.Initials) = 0 OR rt.initials = ' ' OR rt.lastname = ' none' THEN
--     null
--   else
--   rt.Initials
--   END as performedBy,
--   tf.intervalindays
--
-- FROM Cln_Medications m
--   left join Cln_MedicationTimes cln on (m.SearchKey = cln.SearchKey)
--   left join ref_snomed sno on (sno.SnomedCode = m.Medication)
--   left join Sys_parameters s2 on (s2.Field = 'MedicationUnits' and s2.Flag = m.Units)
--   left join Sys_parameters s3 on (s3.Field = 'MedicationRoute' and s3.Flag = m.Route)
--   left join Ref_Technicians rt ON (rt.ID = m.Technician)
--   left join Sys_parameters s6 on (s6.Field = 'DepartmentCode' and s6.Flag = rt.DeptCode)
--
--   left join Sys_parameters s4 on (s4.Field = 'MedicationFrequency' and s4.Flag = Frequency)
--   left join labkey.ehr_lookups.treatment_frequency tf ON (tf.meaning = s4.value)
--   left join Af_Qrf q on (q.animalid = m.animalid)
--   left join labkey.ehr_lookups.snomed_subset_codes ss ON (ss.code = m.Medication AND ss.primaryCategory = 'Diet' and ss.container = (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC'))
--
-- where m.AnimalId is not null
-- and (cln.ts > ? or m.ts > ? or q.ts > ?)
-- ) t1
--
-- ) t
--
-- LEFT JOIN labkey.ldk.integers i on (i.value < t.Duration AND ((i.value + 1) % t.intervalindays = 0))
--
-- ) t2
--
-- WHERE t2.date >= t2.treatmentStartDate and t2.date <= t2.treatmentEndDate
--
-- UNION ALL

SELECT
    cast(g.AnimalId as nvarchar(4000)) as Id,
	g.Date,
    null as treatmentStartDate,
    null as treatmentEndDate,
    --null as datetime,

	AnesthesiaGas as code,
    sno.Description as meaning,

	'IV Location: ' + coalesce(s1.Value, '') + '\n' +
	'IV Side: ' + coalesce(s2.Value, '') + '\n' +
	'IV Tube Size: ' + coalesce(s3.Value, '') + '\n'
	as remark,
--       ,[Ventilator]   --boolean

	null as amount,
	null as amount_Units,
	'IV' as Route,
	cast(h.objectid as varchar(38)) as objectid,
	g.objectid as parentId,
	null as treatmentId,
  null as timeordered,

	null as performedby,
	'Anesthesia' as category,
	c.objectid as caseid

FROM Sur_AnesthesiaLogHeader h
LEFT JOIN sur_general g ON (g.surgeryid = h.surgeryid)
left join ref_snomed sno on (sno.SnomedCode = h.AnesthesiaGas)
LEFT JOIN Sys_parameters s1 ON (s1.Field = 'IVLocation' AND s1.Flag = h.IVLocation)
LEFT JOIN Sys_parameters s2 ON (s1.Field = 'IVSide' AND s2.Flag = h.IVSide)
LEFT JOIN Sys_parameters s3 ON (s3.Field = 'GasTubeSize' AND s3.Flag = h.TubeSize)
left join (
	select c.AnimalID, max(ts) as ts, count(c.CaseID) as count, max(CAST(c.objectid AS varchar(36))) as objectid, c.OpenDate as date
	from af_case c
	WHERE c.GroupCode = 2
	GROUP BY c.AnimalID, c.OpenDate
) c ON (c.AnimalID = g.AnimalID AND c.date = g.date)

WHERE h.ts > ? or g.ts > ?

UNION ALL

SELECT
cast(g.AnimalId as nvarchar(4000)) as Id,
g.Date,
null as treatmentStartDate,
null as treatmentEndDate,
Medication as code,
sno.Description as meaning,
null as remark,
Dose as amount,
s2.value as amount_units,
s3.value as Route,
cast(m.objectid as varchar(38)) as objectid,
g.objectid as parentid,
null as treatmentId,
null as timeordered,
null as performedby,
'Surgical' as category,
c.objectid as caseid

FROM Sur_Medications m
	left join Sur_General g on (g.SurgeryID = m.SurgeryID)
	left join Ref_SnoMed sno on (sno.SnomedCode = m.Medication)
	left join Sys_parameters s2 on (s2.Field = 'MedicationUnits' and s2.Flag = m.Units)
	left join Sys_parameters s3 on (s3.Field = 'MedicationRoute' and s3.Flag = m.Route)
    left join (
        select c.AnimalID, max(ts) as ts, count(c.CaseID) as count, max(CAST(c.objectid AS varchar(36))) as objectid, c.OpenDate as date
        from af_case c
        WHERE c.GroupCode = 2
        GROUP BY c.AnimalID, c.OpenDate
    ) c ON (c.AnimalID = g.AnimalID AND c.date = g.date)

WHERE m.ts > ? or g.ts > ?

-- --implant data
-- UNION ALL
--
-- SELECT
--   cast(v.AnimalId as nvarchar(4000)) as Id,
--   v.Date,
--   null as treatmentStartDate,
--   null as treatmentEndDate,
--   null as code,
--   null as meaning,
--   v.comments as remark,
--   v.implantcount as amount,
--   null as amount_units,
--   null as Route,
--   cast(v.objectid as varchar(38)) as objectid,
--   v.objectid as parentid,
--   null as treatmentId,
--   null as performedby,
--   'Surgical' as category,
--   null as caseid
--
--   --TODO:
--   --s1.Value as size,
--   --s2.Value as type,
--   --s3.Value as site,
--   --s4.Value as action,
--
-- from Sur_Implants v
--   LEFT JOIN Sys_parameters s1 ON (s1.Field = 'ImplantSize' AND s1.Flag = v.size)
--   LEFT JOIN Sys_parameters s2 ON (s2.Field = 'ImplantType' AND s2.Flag = v.type)
--   LEFT JOIN Sys_parameters s3 ON (s3.Field = 'ImplantSite' AND s3.Flag = v.site)
--   LEFT JOIN Sys_parameters s4 ON (s4.Field = 'ImplantAction' AND s4.Flag = v.action)
--   LEFT JOIN Sys_parameters s5 ON (s5.Field = 'SurgeryChargeCode' AND s5.Flag = v.chargecode)
--
-- WHERE v.ts > ?

-- ) d
--
-- WHERE d.projectTs > ?