--Please note:  All lab values = -1 is should be substitued with a Null value

SELECT
	t.ClinicalKey ,
	cast(t.Id as varchar) as Id,
	t.DATE ,
	--t.Specimen ,     --      Speciment database table
	--sp.Name,
	--sp.SNOMEDCODE as snomed,
	t.MethodInt  ,
	s2.Value as PerformedBy,
	t.CollectionInt  ,
	s5.Value as method,
	
	t.QualResult,
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
	Collection as CollectionInt  ,
	null as result,
	s4.value as QualResult,
	'Appearance' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s4 on (s4.Field = 'UrineAppearance' and s4.Flag = Appearance)

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	s6.value as QualResult,
	'Color' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s6 on (s6.Field = 'UrineColor' and s6.Flag = Color)

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	s7.value as QualResult,
	'Bacteria' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s7 on (s7.Field = 'BacteriaCount' and s7.Flag = Bacteria)

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	s8.value as QualResult,
	'Protein' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s8 on (s8.Field = 'UrineMeasurement' and s8.Flag = Protein)

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	s9.value as QualResult,
	'Glucose' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s9 on (s9.Field = 'UrineMeasurement' and s9.Flag = Glucose)

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	s10.value as QualResult,
	'Ketone' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s10 on (s10.Field = 'UrineMeasurement' and s10.Flag = Ketone)

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	s11.value as QualResult,
	'Bilirubin' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s11 on (s11.Field = 'UrineMeasurement' and s11.Flag = Bilirubin)

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	s12.value as QualResult,
	'Blood' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s12 on (s12.Field = 'UrineMeasurement' and s12.Flag = Blood)

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	s13.value as QualResult,
	'CastsType1' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s13 on (s13.Field = 'Casts' and s13.Flag = CastsType1)

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	s14.value as QualResult,
	'CastsType2' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
left join Sys_parameters s14 on (s14.Field = 'Casts' and s14.Flag = CastsType2)

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	RBCMin as result,
	null as QualResult,
	'RBCMin' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	RBCMax as result,
	null as QualResult,
	'RBCMax' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	WBCMin as result,
	null as QualResult,
	'WBCMin' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	WBCMax as result,
	null as QualResult,
	'WBCMax' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	SpecificGravity as result,
	null as QualResult,
	'SpecificGravity' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	EpitheliaMin as result,
	null as QualResult,
	'EpitheliaMin' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	EpitheliaMax as result,
	null as QualResult,
	'EpitheliaMax' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	PHValue as result,
	null as QualResult,
	'PHValue' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	CastsMin as result,
	null as QualResult,
	'CastsMin' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	CastsMax as result,
	null as QualResult,
	'CastsMax' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	Crystals as result,
	null as QualResult,
	'Crystals' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	Urobilinogen as result,
	null as QualResult,
	'Urobilinogen' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Collection as CollectionInt  ,
	null as result,
	Other as QualResult,
	'Other' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln

) t

left join Sys_parameters s2 on (s2.Field = 'AnalysisMethodUrinalysis' and s2.Flag = t.MethodInt)
left join Sys_parameters s5 on (s5.Field = 'UrineCollection' and s5.Flag = t.CollectionInt)
--left join Specimen sp on (sp.Value = t.Specimen)

where t.rowversion > ?
