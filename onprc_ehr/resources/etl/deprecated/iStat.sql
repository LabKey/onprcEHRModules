/*
 * Copyright (c) 2013-2017 LabKey Corporation
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
--Please note:  All lab values = -1 is should be substitued with a Null value

SELECT
	--t.ClinicalKey ,
	cast(t.Id as nvarchar(4000)) as Id,
	t.DATE ,
	--t.Specimen ,     --      Specimen database table
	--sp.Name,
	--sp.SNOMEDCODE as snomed,
	t.MethodInt  ,
	s2.Value as Method,
	case
	  when t.Result = -1 then null
	  else t.Result
    end as Result,
    t.resultString as stringResults,

	t.TestId,

	t.rowversion,
	(cast(t.objectid as varchar(38)) + '_' + t.TestId) as objectid,
	 null as parentId,
	 t.objectid as runId

FROM (


SELECT
	null as IDKey,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,       ------ Specimen  database table
	Method as MethodInt  ,
	null as result,
	Sodium as ResultString,
	'Na' as TestId,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_IStat cln

UNION ALL

SELECT
	null as IDKey,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,       ------ Specimen  database table
	Method as MethodInt  ,
	null as result,
	Potassium as ResultString,
	'K' as TestId,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_IStat cln

UNION ALL

SELECT
	null as IDKey,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,       ------ Specimen  database table
	Method as MethodInt  ,
	null as result,
	Chlorine as ResultString ,
	'Cl' as TestId,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_IStat cln

UNION ALL

SELECT
	null as IDKey,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,       ------ Specimen  database table
	Method as MethodInt  ,
	null as result,
	TCO2 as ResultString,
	'TCO2' as TestId,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_IStat cln

UNION ALL

SELECT
	null as IDKey,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,       ------ Specimen  database table
	Method as MethodInt  ,
	null as result,
	BUN as ResultString ,
	'BUN' as TestId,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_IStat cln

UNION ALL

SELECT
	null as IDKey,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,       ------ Specimen  database table
	Method as MethodInt  ,
	null as result,
	Glu as ResultString,
	'Glu' as TestId,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_IStat cln

UNION ALL

SELECT
	null as IDKey,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,       ------ Specimen  database table
	Method as MethodInt  ,
	null as result,
	Hct as ResultString ,
	'HCT' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_IStat cln

UNION ALL

SELECT
	null as IDKey,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,       ------ Specimen  database table
	Method as MethodInt  ,
	null as result,
	PH as ResultString,
	'pH' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_IStat cln

UNION ALL

SELECT
	null as IDKey,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,       ------ Specimen  database table
	Method as MethodInt  ,
	null as result,
	PCO2 as ResultString,
	'pCO2' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_IStat cln

UNION ALL

SELECT
	null as IDKey,
	AnimalID as Id  ,
	DATE ,

	Specimen as Specimen ,       ------ Specimen  database table
	Method as MethodInt  ,
	null as result,
	HCO3 as ResultString,
	'HCO3' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_IStat cln

UNION ALL

SELECT
	null as IDKey,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,       ------ Specimen  database table
	Method as MethodInt  ,
	null as result,
	BE as ResultString,
	'BE' as TestId,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_IStat cln

UNION ALL

SELECT
	null as IDKey,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,       ------ Specimen  database table
	Method as MethodInt  ,
	null as result,
	AnGap as ResultString ,
	'AnGap' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_IStat cln

UNION ALL

SELECT
	null as IDKey,
	AnimalID as Id  ,
	DATE ,

	Specimen as Specimen ,       ------ Specimen  database table
	Method as MethodInt  ,
	null as result,
	Hgb as ResultString,
	'Hb' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_IStat cln

UNION ALL

SELECT
	null as IDKey,
	AnimalID as Id  ,
	DATE ,

	Specimen as Specimen ,       ------ Specimen  database table
	Method as MethodInt  ,
	null as result,
	PO2 as ResultString,
	'pO2' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_IStat cln

UNION ALL

SELECT
	null as IDKey,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,       ------ Specimen  database table
	Method as MethodInt  ,
	null as result,
	SO2 as ResultString,
	'SO2' as TestId,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_IStat cln

UNION ALL

SELECT
	null as IDKey,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,       ------ Specimen  database table
	Method as MethodInt  ,
	null as result,
	LAC as ResultString,
	'Lact' as TestId,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_IStat cln

) t

left join Sys_Parameters s2 on (s2.Flag = t.MethodInt And s2.Field = 'AnalysisMethodBiochem')

WHERE t.ResultString is not null and t.ResultString != ''
  AND t.rowversion > ?
