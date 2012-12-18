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
    cast(m.AnimalId as nvarchar(4000)) as Id,

    --TODO: revisit
	m.Date,
	convert(datetime, CONVERT(varchar, m.date, 111) + ' ' + left(cln.MedicationTime, 2) + ':' + RIGHT(cln.medicationtime, 2)) as datetime,

	Medication as code,
	sno.Description as meaning,
	Dose as Dose,
	--Units as UnitsInt ,
	s2.Value as Units,
	--Route as RouteInt ,
	s3.Value as Route,
	--cln.IDKey,
	--cln.SearchKey as SearchKey ,
	--cln.ts as rowversion,
	cln.objectid

FROM Cln_MedicationTimes cln
left join Cln_Medications m on (m.SearchKey = cln.SearchKey)
left join ref_snomed121311 sno on (sno.SnomedCode = m.Medication)
left join Sys_parameters s2 on (s2.Field = 'MedicationUnits' and s2.Flag = m.Units)
left join Sys_parameters s3 on (s3.Field = 'MedicationRoute' and s3.Flag = m.Route)
where m.AnimalId is not null
and cln.ts > ?

UNION ALL

SELECT
    cast(g.AnimalId as nvarchar(4000)) as Id,
	g.Date,
    null as datetime,

	AnesthesiaGas as code,
    sno.Description as meaning,

--     TODO
--     [IVLocation]
--       ,[IVSide]
--       ,[Ventilator]   --boolean
--       ,[TubeSize]

	null as Dose,
	null as Units,
	'IV' as Route,
	m.objectid

FROM Sur_AnesthesiaLogHeader m
LEFT JOIN sur_general g ON (g.surgeryid = m.surgeryid)
left join ref_snomed121311 sno on (sno.SnomedCode = m.AnesthesiaGas)
--LEFT JOIN Sys_parameters s1 ON (s1.Field = 'IVLocation' AND s1.Flag = v.IVLocation)
--LEFT JOIN Sys_parameters s2 ON (s1.Field = 'IVSide' AND s2.Flag = m.IVSide)
--LEFT JOIN Sys_parameters s3 ON (s3.Field = 'GasTubeSize' AND s3.Flag = m.TubeSize)

WHERE m.ts > ?