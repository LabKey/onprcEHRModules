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
	t.ClinicalKey ,
	cast(t.Id as nvarchar(4000)) as Id,
	t.DATE ,
	--t.Specimen ,     --      Specimen database table
  t.projectId as project,
	--sp.Name,
	--sp.SNOMEDCODE as snomed,
	--t.MethodInt  ,
	s2.Value as Method,
	CASE
	  WHEN t.result = -1 THEN null
	  else t.result
  END as result,
  t.qual_result,

	t.TestId,

	t.remarks as remark,
	(cast(t.objectid as varchar(38)) + '_' + t.TestId) as objectid,
	 t.objectid as runid

FROM (

-- SELECT
-- 	ClinicalKey ,
-- 	AnimalID as Id  ,
-- 	DATE ,
-- 	Specimen as Specimen ,     --      Specimen database table
-- 	Method as MethodInt  ,
-- 	ManualDiff as Result,
-- 	'ManualDiff' as TestId,
-- 	cln.ts as rowversion,
-- 	cln.objectid
--
-- FROM Cln_Hematology cln
-- WHERE ManualDiff != 0
--
-- union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	WBC as Result,
  null as qual_result,
	'WBC' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	RBC as Result,
  null as qual_result,
	'RBC' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Hemoglobin as Result,
  null as qual_result,
	'HGB' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Hematocrit as Result,
  null as qual_result,
	'HCT' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	MCV as Result,
  null as qual_result,
	'MCV' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	MCH as Result,
  null as qual_result,
	'MCH' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	MCHC as Result,
  null as qual_result,
	'MCHC' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	PlateletCount as Result,
  null as qual_result,
	'PLT' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	TotalProtein as Result,
  null as qual_result,
	'TP' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	MPMN as Result,
  null as qual_result,
	'NEUT%' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	IPMN as Result,
  null as qual_result,
	'Bands' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Lymphocyte as Result,
  null as qual_result,
	'LYMPH%' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Monocyte as Result,
  null as qual_result,
	'MONO%' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Eosinophil as Result,
  null as qual_result,
	'EOS%' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Basophil as Result,
  null as qual_result,
	'BASO%' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	SEDRate as Result,
  null as qual_result,
	'SEDRate' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	LUC as Result,
  null as qual_result,
	'LUC' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	NRBC as Result,
  null as qual_result,
	'NRBC' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Reticulocyte as Result,
  null as qual_result,
	'RETIC' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	RBCHypochromic as Result,
  null as qual_result,
	'Hypochromic RBC' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
  ClinicalKey ,
  projectId,
  AnimalID as Id  ,
  DATE ,
  Specimen as Specimen ,     --      Specimen database table
  Method as MethodInt  ,
  cast(RBC_Acanthocytes as double precision) as Result,
  null as qual_result,
  'RBC Acanthocytes' as TestId,
  cln.ts as rowversion,
  cln.remarks,
  cln.objectid

FROM Cln_Hematology cln

union all

SELECT
  ClinicalKey ,
  projectId,
  AnimalID as Id  ,
  DATE ,
  Specimen as Specimen ,     --      Specimen database table
  Method as MethodInt  ,
  cast(RBC_Poikilocytes as double precision) as Result,
  null as qual_result,
  'RBC Poikilocytes' as TestId,
  cln.ts as rowversion,
  cln.remarks,
  cln.objectid

FROM Cln_Hematology cln

union all

SELECT
  ClinicalKey ,
  projectId,
  AnimalID as Id  ,
  DATE ,
  Specimen as Specimen ,     --      Specimen database table
  Method as MethodInt  ,
  cast(RBC_Spherocytes as double precision) as Result,
  null as qual_result,
  'RBC Spherocytes' as TestId,
  cln.ts as rowversion,
  cln.remarks,
  cln.objectid

FROM Cln_Hematology cln

union all

SELECT
  ClinicalKey ,
  projectId,
  AnimalID as Id  ,
  DATE ,
  Specimen as Specimen ,     --      Specimen database table
  Method as MethodInt  ,
  null as result,
  RBC_TargetCells as qual_result,
  'RBC TargetCells' as TestId,
  cln.ts as rowversion,
  cln.remarks,
  cln.objectid

FROM Cln_Hematology cln

union all

SELECT
  ClinicalKey ,
  projectId,
  AnimalID as Id  ,
  DATE ,
  Specimen as Specimen ,     --      Specimen database table
  Method as MethodInt  ,
  MPV as Result,
  null as qual_result,
  'MPV' as TestId,
  cln.ts as rowversion,
  cln.remarks,
  cln.objectid

FROM Cln_Hematology cln

union all

SELECT
  ClinicalKey ,
  projectId,
  AnimalID as Id  ,
  DATE ,
  Specimen as Specimen ,     --      Specimen database table
  Method as MethodInt  ,
  RDW as Result,
  null as qual_result,
  'RDW' as TestId,
  cln.ts as rowversion,
  cln.remarks,
  cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	RBCMicrocyte as Result,
  null as qual_result,
	'Microcytic RBC' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	RBCPolychromasia as Result,
  null as qual_result,
	'Polychromasia RBC' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	RBCMacrocyte as Result,
  null as qual_result,
	'Macrocytic RBC' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
  projectId,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	RBCAnisocytosis as Result,
  null as qual_result,
	'Anisocytosis' as TestId,
	cln.ts as rowversion,
  cln.remarks,
	cln.objectid

FROM Cln_Hematology cln

) t

left join Sys_Parameters s2 on (s2.Flag = t.MethodInt And s2.Field = 'AnalysisMethodHematology')
--left join Specimen sp on (sp.Value = t.Specimen)

WHERE t.result != -1 AND (t.result is not null or t.qual_result is not null)
  and t.rowversion > ?

