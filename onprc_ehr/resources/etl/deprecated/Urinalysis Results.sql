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
	--t.Specimen ,     --      Specimen database table
	--sp.Name,
	--sp.SNOMEDCODE as snomed,
	t.MethodInt  ,
	s2.Value as method,

	t.CollectionInt  ,
	s5.Value as collectionMethod,
	t.result,
	t.rangeMax,
	t.QualResult,
	t.TestId,

	--t.rowversion,
	(cast(t.objectid as varchar(38)) + '_' + t.TestId) as objectid,
	 t.objectid as runid

FROM (

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	null as rangeMax,
	s4.value as QualResult,
	'App' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s4 on (s4.Field = 'UrineAppearance' and s4.Flag = Appearance)
where s4.value is not null

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	null as rangeMax,
	s6.value as QualResult,
	'Color' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s6 on (s6.Field = 'UrineColor' and s6.Flag = Color)
where s6.value is not null

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	null as rangeMax,
	s7.value as QualResult,
	'Bact' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s7 on (s7.Field = 'BacteriaCount' and s7.Flag = Bacteria)
where s7.value is not null

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	null as rangeMax,
	s8.value as QualResult,
	'Prot' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s8 on (s8.Field = 'UrineMeasurement' and s8.Flag = Protein)
where s8.value is not null

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	null as rangeMax,
	s9.value as QualResult,
	'Glu' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s9 on (s9.Field = 'UrineMeasurement' and s9.Flag = Glucose)
where s9.value is not null

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	null as rangeMax,
	s10.value as QualResult,
	'Ket' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s10 on (s10.Field = 'UrineMeasurement' and s10.Flag = Ketone)
where s10.value is not null

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	null as rangeMax,
	s11.value as QualResult,
	'Bili' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s11 on (s11.Field = 'UrineMeasurement' and s11.Flag = Bilirubin)
where s11.value is not null

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	null as rangeMax,
	s12.value as QualResult,
	'Blood' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s12 on (s12.Field = 'UrineMeasurement' and s12.Flag = Blood)
where s12.value is not null

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	null as rangeMax,
	s13.value as QualResult,
	'Cast-1' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s13 on (s13.Field = 'Casts' and s13.Flag = CastsType1)
where s13.value is not null

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	null as rangeMax,
	s14.value as QualResult,
	'Cast-2' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s14 on (s14.Field = 'Casts' and s14.Flag = CastsType2)
where s14.value is not null

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	CASE WHEN RBCMin != -1 THEN RBCMin ELSE NULL END as result,
	CASE WHEN RBCMax != -1 THEN RBCMax ELSE NULL END as rangeMax,
	null as QualResult,
	'RBC' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
WHERE RBCMin != 0

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	CASE WHEN WBCMin != -1 THEN WBCMin ELSE null END as result,
	CASE WHEN WBCMax != -1 THEN WBCMax ELSE null END as rangeMax,
	null as QualResult,
	'WBC' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
WHERE WBCMin is not null

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	SpecificGravity as result,
	null as rangeMax,
	null as QualResult,
	'SpecGrav' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
WHERE SpecificGravity is not null and SpecificGravity != -1

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	CASE WHEN EpitheliaMin != -1 THEN EpitheliaMin ELSE null END as result,
	CASE WHEN EpitheliaMax != -1 THEN EpitheliaMax ELSE null END as rangeMax,
	null as QualResult,
	'Epith' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
WHERE EpitheliaMin is not null

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	PHValue as result,
	null as rangeMax,
	null as QualResult,
	'pH' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
WHERE cln.PHValue IS NOT NULL and cln.PHValue != -1

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	CASE WHEN CastsMin != -1 THEN CastsMin ELSE null END as result,
	CASE WHEN CastsMax != -1 THEN CastsMax ELSE null END as rangeMax,
	null as QualResult,
	'Casts' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
WHERE CastsMin is not null

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	null as rangeMax,
	Crystals as QualResult,
	'Crystals' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
WHERE Crystals is not null and Crystals != ''

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	null as rangeMax,
	Urobilinogen as QualResult,
	'Urobili' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
WHERE Urobilinogen is not null and Urobilinogen != ''

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	null as rangeMax,
	Other as QualResult,
	'Other' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
WHERE Other is not null and Other != ''

) t

left join Sys_parameters s2 on (s2.Field = 'AnalysisMethodUrinalysis' and s2.Flag = t.MethodInt)
left join Sys_parameters s5 on (s5.Field = 'UrineCollection' and s5.Flag = t.CollectionInt)

where t.rowversion > ?
