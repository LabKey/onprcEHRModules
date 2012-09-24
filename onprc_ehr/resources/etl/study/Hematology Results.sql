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
	CASE
	  WHEN t.result = -1 THEN null
	  else t.result
    END as result,

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
	ManualDiff as Result,
	'ManualDiff' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	WBC as Result,
	'WBC' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	RBC as Result,
	'RBC' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Hemoglobin as Result,
	'Hemoglobin' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Hematocrit as Result,
	'Hematocrit' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	MCV as Result,
	'MCV' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	MCH as Result,
	'MCH' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	MCHC as Result,
	'MCHC' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	PlateletCount as Result,
	'PlateletCount' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	TotalProtein as Result,
	'TotalProtein' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	MPMN as Result,
	'MPMN' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	IPMN as Result,
	'IPMN' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Lymphocyte as Result,
	'Lymphocyte' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Monocyte as Result,
	'Monocyte' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Eosinophil as Result,
	'Eosinophil' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Basophil as Result,
	'Basophil' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	SEDRate as Result,
	'SEDRate' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	LUC as Result,
	'LUC' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	NRBC as Result,
	'NRBC' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Reticulocyte as Result,
	'Reticulocyte' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	RBCHypochromic as Result,
	'RBCHypochromic' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	RBCMicrocyte as Result,
	'RBCMicrocyte' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	RBCPolychromasia as Result,
	'RBCPolychromasia' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	RBCMacrocyte as Result,
	'RBCMacrocyte' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	RBCAnisocytosis as Result,
	'RBCAnisocytosis' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln

UNION ALL


--TODO: does tihs belong here??
SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	TotalWBC as Result,
	'TotalWBC' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_CerebralspinalFluid cln

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	WBCNeurophils as Result,
	'WBCNeurophils' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_CerebralspinalFluid cln

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	WBCLymphocytes as Result,
	'WBCLymphocytes' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_CerebralspinalFluid cln

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	TotalProtein as Result,
	'TotalProtein' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_CerebralspinalFluid cln

UNION ALL

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	Glucose as Result,
	'Glucose' as TestId,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_CerebralspinalFluid cln

) t

left join Sys_Parameters s2 on (s2.Flag = t.MethodInt And s2.Field = 'AnalysisMethodHematology')
--left join Specimen sp on (sp.Value = t.Specimen)

WHERE t.result != -1
  and t.rowversion > ?

