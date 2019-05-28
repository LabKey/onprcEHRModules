/*
 * Copyright (c) 2012-2017 LabKey Corporation
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
  t.projectId as project,

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
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Glucose as Result,
	null as resultString,
	'GLU' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
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
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Creatinine as Result,
	null as resultString,
	'CREA' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Sodium as Result,
	null as resultString,
	'NA' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Potassium as Result,
	null as resultString,
	'K' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Chloride as Result,
	null as resultString,
	'CL' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	TotalProtein as Result ,
	null as resultString,
	'TP' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Albumin as Result,
	null as resultString,
	'ALB' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	AGRatio as Result,
	null as resultString,
	'A/G ratio' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Calcium as Result,
	null as resultString,
	'Ca' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Phosphorus as Result,
	null as resultString,
	'PHOS' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	UricAcid as Reuslt,
	null as resultString,
	'UA' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Cholesterol as Result,
	null as resultString,
	'CHOL' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Triglycerides as Result,
	null as resultString,
	'TRIG' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	AlkPhosphotase as Result,
	null as resultString,
	'ALKP' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
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
  projectid,
	Specimen as Specimen ,     --      Specimen database table
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
  projectid,
	Specimen as Specimen ,     --      Specimen database table
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
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Iron as Result,
	null as resultString,
	'Fe' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
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
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Globulin as Result,
	null as resultString,
	'Glob' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	TotalBilirubin as Result,
	null as resultString,
	'TBIL' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	DirectBilirubin as Result,
	null as resultString,
	'DBIL' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	BunCreat as Result,
	null as resultString,
	'B/C' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	RefAmylase as Result,
	null as resultString,
	'Amyl' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	RefLipase as Result,
	null as resultString,
	'Lip' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	RefCPK as Result,
	null as resultString,
	'CPK' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	HDL_CHOL as Result,
	null as resultString,
	'HDL' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
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
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	CHOL_HDL as Result,
	null as resultString,
	'CHOL/HDL' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	LDL_HDL as Result,
	null as resultString,
	'LDL/HDL' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	CK as Result,
	null as resultString,
	'CPK' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
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
  projectid,
	Specimen as Specimen ,     --      Specimen database table
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
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	LACT as Result,
	null as resultString,
	--TODO: review w/ chris
	'LDH' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
  projectid,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	VLDL_Cholesterol as Result,
	null as resultString,
	'VLDL/CHOL' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Biochemistry cln

) t

left join Sys_Parameters s2 on (s2.Flag = t.MethodInt And s2.Field = 'AnalysisMethodBiochem')

WHERE result != -1
  AND t.rowversion > ?
