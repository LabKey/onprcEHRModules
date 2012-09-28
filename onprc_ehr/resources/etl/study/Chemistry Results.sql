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
--Please note:  All lab values = -1 is should be substitued with a Null value

SELECT
	t.ClinicalKey ,
	cast(t.Id as varchar) as Id,
	t.DATE ,
	--t.Specimen ,     --      Speciment database table
	--sp.Name,
	--sp.SNOMEDCODE as snomed,
	t.MethodInt  ,
	s2.Value as Method,
	case
	  when t.Result = -1 then null
	  else t.Result
    end as Result,
    t.resultString,

	t.TestId,

	t.rowversion,
	(cast(t.objectid as varchar(38)) + '_' + t.TestId) as objectid,
	 t.objectid as parentId

FROM (

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Glucose as Result,
	null as resultString,
	'Glucose' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	BUN as Result,
	null as resultString,
	'BUN' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Creatinine as Result,
	null as resultString,
	'Creatinine' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Sodium as Result,
	null as resultString,
	'Sodium' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Potassium as Result,
	null as resultString,
	'Potassium' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Chloride as Result,
	null as resultString,
	'Chloride' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	TotalProtein as Result ,
	null as resultString,
	'TotalProtein' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Albumin as Result,
	null as resultString,
	'Albumin' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	AGRatio as Result,
	null as resultString,
	'AGRatio' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Calcium as Result,
	null as resultString,
	'Calcium' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Phosphorus as Result,
	null as resultString,
	'Phosphorus' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	UricAcid as Reuslt,
	null as resultString,
	'UricAcid' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Cholesterol as Result,
	null as resultString,
	'Cholesterol' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Triglycerides as Result,
	null as resultString,
	'Triglycerides' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	AlkPhosphotase as Result,
	null as resultString,
	'AlkPhosphotase' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	LDH as Result,
	null as resultString,
	'LDH' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	AST as Result,
	null as resultString,
	'AST' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	ALT as Result,
	null as resultString,
	'ALT' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Iron as Result,
	null as resultString,
	'Iron' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	GGT as Result,
	null as resultString,
	'GGT' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Globulin as Result,
	null as resultString,
	'Globulin' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	TotalBilirubin as Result,
	null as resultString,
	'TotalBilirubin' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	DirectBilirubin as Result,
	null as resultString,
	'DirectBilirubin' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	BunCreat as Result,
	null as resultString,
	'BunCreat' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	RefAmylase as Result,
	null as resultString,
	'RefAmylase' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	RefLipase as Result,
	null as resultString,
	'RefLipase' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	RefCPK as Result,
	null as resultString,
	'RefCPK' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	HDL_CHOL as Result,
	null as resultString,
	'HDL_CHOL' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	LDL as Result,
	null as resultString,
	'LDL' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	CHOL_HDL as Result,
	null as resultString,
	'CHOL_HDL' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	LDL_HDL as Result,
	null as resultString,
	'LDL_HDL' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	CK as Result,
	null as resultString,
	'CK' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	MG as Result,
	null as resultString,
	'MG' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	CRP as Result,
	null as resultString,
	'CRP' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	LACT as Result,
	null as resultString,
	'LACT' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	VLDL_Cholesterol as Result,
	null as resultString,
	'VLDL_Cholesterol' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

UNION ALL

SELECT
	null as IDKey,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,       ------ Specimen  database table
	Method as MethodInt  ,
	null as result,
	Sodium as ResultString,
	'Sodium' as TestId,

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
	'Potassium' as TestId,

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
	'Chlorine' as TestId,

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
	'Hct' as TestId,
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
	'PH' as TestId,
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
	'PCO2' as TestId,
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
	'Hgb' as TestId,
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
	'PO2' as TestId,
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
	'LAC' as TestId,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_IStat cln

) t

left join Sys_Parameters s2 on (s2.Flag = t.MethodInt And s2.Field = 'AnalysisMethodBiochem')

WHERE result != -1
  AND t.rowversion > ?
