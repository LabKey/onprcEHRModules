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
SELECT
	t.Id,
	DATEADD (DAY , i.value, t.date) as date,
	--t.duration,
	--i.value,
	t.code,
	t.meaning,
	t.remark,
	t.amount,
	t.amount_units,
	t.route,
	(cast(t.objectid as varchar(38)) + '_' + cast(i.value as varchar(10))) as objectid,
	t.parentId,
	t.treatmentId,
	t.performedBy

FROM (
	SELECT
		coalesce(m.duration, 0) as duration,
		cast(m.AnimalId as nvarchar(4000)) as Id,

		case
		  when cln.MedicationTime is null or cln.MedicationTime = '' or LEN(medicationtime) = 0 then m.date
		  when LEN(medicationtime) = 3 then convert(datetime, CONVERT(varchar(100), m.date, 111) + ' 0' + left(cln.MedicationTime, 1) + ':' + RIGHT(cln.medicationtime, 2))
		  else convert(datetime, CONVERT(varchar(100), m.date, 111) + ' ' + left(cln.MedicationTime, 2) + ':' + RIGHT(cln.medicationtime, 2))
		end as date,

		Medication as code,
		sno.Description as meaning,

		null as remark,
		Dose as amount,

		--Units as UnitsInt ,
		s2.Value as amount_units,
		--Route as RouteInt ,
		s3.Value as route,
		coalesce(cln.objectid, m.objectid) as objectid,
		null as parentId,
		m.objectId as treatmentId,

		case
		  WHEN rt.LastName = 'Unassigned' or rt.FirstName = 'Unassigned' THEN
			'Unassigned'
		  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 AND datalength(rt.Initials) > 0 THEN
			rt.LastName + ', ' + rt.FirstName + ' (' + rt.Initials + ')'
		  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 THEN
			rt.LastName + ', ' + rt.FirstName
		  WHEN datalength(LastName) > 0 AND datalength(rt.Initials) > 0 THEN
			rt.LastName + ' (' + rt.Initials + ')'
		  WHEN datalength(rt.Initials) = 0 OR rt.initials = ' ' OR rt.lastname = ' none' THEN
			null
		  else
		   rt.Initials
		END as performedBy

	FROM Cln_Medications m
	left join Cln_MedicationTimes cln on (m.SearchKey = cln.SearchKey)
	left join ref_snomed sno on (sno.SnomedCode = m.Medication)
	left join Sys_parameters s2 on (s2.Field = 'MedicationUnits' and s2.Flag = m.Units)
	left join Sys_parameters s3 on (s3.Field = 'MedicationRoute' and s3.Flag = m.Route)
	left join Ref_Technicians rt ON (rt.ID = m.Technician)
	where m.AnimalId is not null
	and (cln.ts > ? or m.ts > ?)
) t

LEFT JOIN labkey.ldk.integers i on (i.value < t.Duration)


UNION ALL

SELECT
    cast(g.AnimalId as nvarchar(4000)) as Id,
	g.Date,
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
	h.objectid,
	g.objectid as parentId,
	null as treatmentId,
	
	null as performedby

FROM Sur_AnesthesiaLogHeader h
LEFT JOIN sur_general g ON (g.surgeryid = h.surgeryid)
left join ref_snomed sno on (sno.SnomedCode = h.AnesthesiaGas)
LEFT JOIN Sys_parameters s1 ON (s1.Field = 'IVLocation' AND s1.Flag = h.IVLocation)
LEFT JOIN Sys_parameters s2 ON (s1.Field = 'IVSide' AND s2.Flag = h.IVSide)
LEFT JOIN Sys_parameters s3 ON (s3.Field = 'GasTubeSize' AND s3.Flag = h.TubeSize)

WHERE h.ts > ? or g.ts > ?