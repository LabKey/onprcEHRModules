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
SELECT
  cast(Id as varchar(4000)) as Id,
  date,
  CASE
    WHEN projectId IN (470,1173,1455) THEN 625
    ELSE projectId
  END as project,
  CASE
    WHEN (projectId IS NULL AND servicerequested is not null) THEN 'Not Billable'
    ELSE null
  END as chargetype,

    servicerequested,
	category as type,
	--CategoryInt ,
	Category2,

  coalesce(t.Tissue, sp.SNOMEDCODE) as tissue,
	Method,
	collectionMethod,

	remarks as remark,

	case
	  WHEN TechLastName = 'Unassigned' or TechFirstName = 'Unassigned' THEN
        'Unassigned'
	  WHEN datalength(TechLastName) > 0 AND datalength(TechFirstName) > 0 AND datalength(TechInitials) > 0 THEN
        TechLastName + ', ' + TechFirstName + ' (' + TechInitials + ')'
	  WHEN datalength(TechLastName) > 0 AND datalength(TechFirstName) > 0 THEN
        TechLastName + ', ' + TechFirstName
	  WHEN datalength(TechLastName) > 0 AND datalength(TechInitials) > 0 THEN
        TechLastName + ' (' + TechInitials + ')'
      WHEN datalength(TechInitials) = 0 OR Techinitials = ' ' OR TechLastName = ' none' THEN
        null
	  else
	   TechInitials
    END as performedBy,

	--t.rowversion,
	t.objectid

FROM (

--AntibioticSensitivity
SELECT
	ClinicalKey as ClinicalKey ,
	AnimalID as Id ,
	DATE as Date ,
    null as projectId,
	'Antibiotic Sensitivity' as category,
    'Antibiotic Sensitivity' as servicerequested,
	Category as CategoryInt  ,
	s1.Value as Category2,
	Technician As TechnicianID,
	LastName as TechLastName,
	FirstName as TechFirstName,
	Initials as TechInitials,
        s4.Value as Department,
	Specimen as Specimen ,            ---- information not required
	Method as MethodInt  ,
	s2.Value as Method,
	null as collectionMethod,
	cln.tissue as Tissue,
	null as remarks,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_AntibioticSensHeader cln
     left join  Ref_Technicians rt on (cln.Technician = rt.ID)
     left join Sys_parameters s1 on (s1.Field = 'RequestCategory'and s1.Flag = Cln.Category)
     left join Sys_parameters s2 on (s2.Field = 'AnalysisMethodAntibiotic'and s2.Flag = Cln.Method)
     left join Sys_parameters s3 on (s3.Field = 'AnimalConditionLab'And s3.Flag = Cln.Condition)
     left join Sys_Parameters s4 on (s4.Field = 'DepartmentCode' and s4.Flag = Rt.Deptcode)


--biochem
union all

SELECT
	ClinicalKey ,
	AnimalID as Id  ,
	DATE ,
    projectId,
	'Biochemistry' as category,
    CASE
      WHEN  cln.panelflag = 15 THEN 'Basic Chemistry Panel in-house'
      WHEN cln.panelflag = 13 THEN  'Comprehensive Chemistry Panel in-house'
      WHEN cln.panelflag = 14 THEN  'Lipid panel in-house: Cholesterol, Triglyceride, HDL, LDL'
      WHEN cln.panelflag = 16 THEN  'High-density lipoprotein & Low-density lipoprotein (HDL & LDL)'
      WHEN cln.panelflag = 17 THEN 'Albumin'
      WHEN cln.panelflag = 18 THEN 'Amylase'
      WHEN cln.panelflag = 16 THEN 'Lipase'
      ELSE null
    END as servicerequested,  --panelflag
	Category as CategoryInt  ,
	s1.Value as Category2,
	Technician As TechnicianID,
	LastName as TechLastName,
	FirstName as TechFirstName,
	Initials as TechInitials,
        s4.Value as Department,

	Specimen as Specimen ,     --      Specimen database table
	Method as MethodInt  ,
	s2.Value as Method,
	null as collectionMethod,

	null as Tissue,
	Remarks  as Remarks,

    cln.ts as rowversion,
    cln.objectid

FROM Cln_Biochemistry cln

     left join Ref_Technicians rt on (Cln.Technician = rt.ID)
     left join Sys_Parameters s1 on (s1.Flag = Cln.Category And s1.Field = 'RequestCategory')
     left join Sys_Parameters s2 on (s2.Flag = Cln.Method And s2.Field = 'AnalysisMethodBiochem')
     left join Sys_Parameters s3 on (s3.Flag = Cln.Condition And s3.Field = 'AnimalConditionLab')
     left join Sys_Parameters s4 on (s4.Flag = rt.DeptCode And s4.Field = 'DepartmentCode')

--iSTAT
union all

SELECT
	IDKey,
	AnimalID as Id  ,
	DATE ,
    null as projectId,
	'iSTAT' as category,
    null as servicerequested,
	Category as CategoryInt  ,
	s1.Value as Category2,

	Technician As TechnicianID,
	LastName as TechLastName,
	FirstName as TechFirstName,
	Initials as TechInitials,
        s4.Value as Department,

	Specimen as Specimen ,       ------ Specimen  database table
	Method as MethodInt  ,
	s2.Value as Method,
	null as collectionMethod,

	null as Tissue,
	null as remarks,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_IStat cln
	     left join Ref_Technicians rt on (Cln.Technician = rt.ID)
     left join Sys_Parameters s1 on (s1.Flag = Cln.Category And s1.Field = 'RequestCategory')
     left join Sys_Parameters s2 on (s2.Flag = Cln.Method And s2.Field = 'AnalysisMethodIStat')
     left join Sys_Parameters s3 on (s3.Flag = Cln.Condition And s3.Field = 'AnimalConditionLab')
     left join Sys_Parameters s4 on (s4.Flag = rt.DeptCode And s4.Field = 'DepartmentCode')


--occult blood
union all

SELECT
	ClinicalKey as ClinicalKey ,
	AnimalID as Id ,
	Date as Date ,
    projectId,
	'Misc Tests' as category,
    'Occult Blood' as servicerequested,
	Category as CategoryInt  ,
	s1.Value as Category2,

	Technician As TechnicianID,
	LastName as TechLastName,
	FirstName as TechFirstName,
	Initials as TechInitials,
	--DeptCode as DepartmentCodeInt,
	s4.Value as DepartmentCode,

	Specimen as Specimen ,			----- Specimen database table
	Method as MethodInt  ,
	s2.Value as Method,
	null as collectionMethod,

	null as Tissue,
	Remarks as Remarks,
	cln.ts as rowversion,
	cln.objectid

FROM Cln_OccultBlood cln
     left join Ref_Technicians rt on (Cln.Technician = rt.ID)
     left join Sys_Parameters s1 on (s1.Flag = Cln.Category And s1.Field = 'RequestCategory')
     left join Sys_Parameters s2 on (s2.Flag = Cln.Method And s2.Field = 'AnalysisMethod')
     left join Sys_Parameters s3 on (s3.Flag = Cln.Condition And s3.Field = 'AnimalConditionLab')
     left join Sys_Parameters s4 on (s4.Flag = rt.DeptCode And s4.Field = 'DepartmentCode')


UNION ALL

SELECT
	ClinicalKey AS ClinicalKey  ,
	AnimalID as Id  ,
	Date,
    projectId,
	'Hematology' as category,
    CASE
      WHEN ManualDiff = 1 THEN 'WBC differential'
      WHEN ManualDiff = 2 THEN 'Reticulocyte count'
      ELSE 'CBC with automated differential'
    END as servicerequested,

	Category as CategoryInt  ,
	s1.Value as Category2,

	Technician As TechnicianID,
	LastName as TechLastName,
	FirstName as TechFirstName,
	Initials as TechInitials,
        s4.Value as Department,

	Specimen ,               ----- Specimen database table
	Method as MethodInt  ,
	s2.Value as Method,
	null as collectionMethod,

    null as Tissue,
	REMARKS as REMARKS,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_Hematology cln
      left join Ref_Technicians rt on (Cln.Technician = rt.ID)
     left join Sys_Parameters s1 on (s1.Flag = Cln.Category And s1.Field = 'RequestCategory')
     left join Sys_Parameters s2 on (s2.Flag = Cln.Method And s2.Field = 'AnalysisMethodHematology')
     left join Sys_Parameters s3 on (s3.Flag = Cln.Condition And s3.Field = 'AnimalConditionLab')
     left join Sys_Parameters s4 on (s4.Flag = rt.DeptCode And s4.Field = 'DepartmentCode')

UNION ALL

SELECT
	ClinicalKey,
	AnimalID as Id  ,
	DATE,
    null as projectId,
	'Cerebral Spinal Fluid' as category,
    null as servicerequested,
	Category as CategoryInt  ,
	s1.Value as Category2,

	Technician As TechnicianID,
	LastName as TechLastName,
	FirstName as TechFirstName,
	Initials as TechInitials,
        s4.Value as Department,

	Specimen as Specimen ,             -------- Specimen database table
	Method as MethodInt  ,
	s2.Value as Method,
	null as collectionMethod,

	null as Tissue,
	REMARKS as REMARKS,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_CerebralspinalFluid cln
     left join Ref_Technicians rt on (Cln.Technician = rt.ID)
     left join Sys_Parameters s1 on (s1.Flag = Cln.Category And s1.Field = 'RequestCategory')
     left join Sys_Parameters s2 on (s2.Flag = Cln.Method And s2.Field = 'AnalysisMethodHematology')
     left join Sys_Parameters s3 on (s3.Flag = Cln.Condition And s3.Field = 'AnimalConditionLab')
     left join Sys_Parameters s4 on (s4.Flag = rt.DeptCode And s4.Field = 'DepartmentCode')

--microbiology
UNION ALL

SELECT
	ClinicalKey as ClinicalKey  ,
	AnimalID as Id ,
	DATE as Date  ,
    projectId,
	'Microbiology' as category,
    null as servicerequested,
	Category as CategoryInt  ,
	s1.Value as Category2,

	Technician As TechnicianID,
	LastName as TechLastName,
	FirstName as TechFirstName,
	Initials as TechInitials,
	--DeptCode as DepartmentCodeInt,
	s4.Value as DepartmentCode,

	Specimen as Specimen ,            ------ Specimen Database table
	Method as MethodInt  ,
	s2.Value as Method,
	null as collectionMethod,

	Tissue as Tissue, 				--- Ref_SnomedLists
	null as remarks,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_MicrobiologyHeader cln
        left join Ref_Technicians rt on (Cln.Technician = rt.ID)
     left join Sys_Parameters s1 on (s1.Flag = Cln.Category And s1.Field = 'RequestCategory')
     left join Sys_Parameters s2 on (s2.Flag = Cln.Method And s2.Field = 'AnalysisMethod')
     left join Sys_Parameters s3 on (s3.Flag = Cln.Condition And s3.Field = 'AnimalConditionLab')
     left join Sys_Parameters s4 on (s4.Flag = rt.DeptCode And s4.Field = 'DepartmentCode')

UNION ALL

SELECT
	ClinicalKey  as ClinicalKey ,
	AnimalID as Id ,
	DATE as Date ,
    projectId,
	'Misc Tests' as category,
    null as servicerequested,
	Category as CategoryInt  ,
	s1.Value as Category2,

	Technician As TechnicianID,
	LastName as TechLastName,
	FirstName as TechFirstName,
	Initials as TechInitials,
	--DeptCode as DepartmentCodeInt,
	s4.Value as Department,

	Specimen as Specimen ,
	Method as MethodInt  ,
	s2.Value as Method,
	null as collectionMethod,

	Tissue as Tissue, 			----- Ref_Snomedlists
	null as remarks,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_RareTestHeader cln
     left join Ref_Technicians rt on (Cln.Technician = rt.ID)
     left join Sys_Parameters s1 on (s1.Flag = Cln.Category And s1.Field = 'RequestCategory')
     left join Sys_Parameters s2 on (s2.Flag = Cln.Method And s2.Field = 'AnalysisMethod')
     left join Sys_Parameters s3 on (s3.Flag = Cln.Condition And s3.Field = 'AnimalConditionLab')
     left join Sys_Parameters s4 on (s4.Flag = rt.DeptCode And s4.Field = 'DepartmentCode')


--virology

UNION ALL

SELECT
	ClinicalKey as ClinicalKey  ,
	AnimalID as Id ,
	DATE as DATE ,
    null as projectId,
	'Serology' as category,
    null as servicerequested,
	Category as CategoryInt  ,
	s1.Value as Category2,
	Technician As TechnicianID,
	LastName as TechLastName,
	FirstName as TechFirstName,
	Initials as TechInitials,
	--DeptCode as DepartmentCodeInt,
	s4.Value as DepartmentCode,
	Specimen as Specimen ,           ----- database table called Specimen
	Method as MethodInt  ,
	s2.Value as Method,
	null as collectionMethod,
	null as Tissue,
	null as remarks,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_VirologyHeader cln
     left join Ref_Technicians rt on (Cln.Technician = rt.ID)
     left join Sys_Parameters s1 on (s1.Flag = Cln.Category And s1.Field = 'RequestCategory')
     left join Sys_Parameters s2 on (s2.Flag = Cln.Method And s2.Field = 'AnalysisMethodHematology')
     left join Sys_Parameters s3 on (s3.Flag = Cln.Condition And s3.Field = 'AnimalConditionLab')
     left join Sys_Parameters s4 on (s4.Flag = rt.DeptCode And s4.Field = 'DepartmentCode')

UNION ALL

SELECT
	ClinicalKey as ClinicalKey ,
	AnimalID as  ID,
	DATE as Date ,
    null as projectId,
	'Serology' as category,
    null as servicerequested,
	Category as CategoryInt  ,
	s1.Value as Category2,

	Technician As TechnicianID,
	LastName as TechLastName,
	FirstName as TechFirstName,
	Initials as TechInitials,
	--DeptCode as DepartmentCodeInt,
	s4.Value as DepartmentCode,

	null as Specimen ,
	Method as MethodInt  ,
      s2.Value  as Method,
      null as collectionMethod,

	null as tissue,
	null as remarks,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_SerologyHeader cln
     left join Ref_Technicians rt on (Cln.Technician = rt.ID)
     left join Sys_Parameters s1 on (s1.Flag = Cln.Category And s1.Field = 'RequestCategory')
      left join Sys_Parameters s2 on (s2.Flag = Cln.Method And s2.Field = 'AnalysisMethod')
     left join Sys_Parameters s3 on (s3.Flag = Cln.Condition And s3.Field = 'AnimalConditionLab')
     left join Sys_Parameters s4 on (s4.Flag = rt.DeptCode And s4.Field = 'DepartmentCode')

--urinalysis
UNION ALL

SELECT
	ClinicalKey as ClinicalKey  ,
	AnimalID as Id  ,
	DATE as Date  ,
    projectId,
	'Urinalysis' as category,
    'Urinalysis' as servicerequested,

	Category as CategoryInt  ,
	s1.Value as Category2,
	cln.Technician As TechnicianID,			--Ref_Technicians
	rt.LastName as TechLastName,
	rt.FirstName as TechFirstName,
	rt.Initials as TechInitials,
	--rt.DeptCode as DepartmentCodeInt,
	s15.Value as Department,
	Specimen as Specimen ,					--database table called Specimen
	Method as MethodInt  ,
	s2.Value as Method,
	s5.value as collectionMethod,
	null as tissue,
	Remarks as Remarks,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_Urinalysis cln
   left join Ref_Technicians rt on ( cln.Technician = rt.ID)
   left join Sys_parameters s1 on (s1.Field = 'RequestCategory' and s1.Flag = Category)
   left join Sys_parameters s2 on (s2.Field = 'AnalysisMethodUrinalysis' and s2.Flag = Method)
   left join Sys_parameters s3 on (s3.Field = 'AnimalConditionLab'and s3.Flag = Condition)
--    left join Sys_parameters s4 on (s4.Field = 'UrineAppearance' and s4.Flag = Appearance)
   left join Sys_parameters s5 on (s5.Field = 'UrineCollection' and s5.Flag = Collection)
   left join Sys_parameters s15 on (s15.Field = 'DepartmentCode' and s15.Flag = rt.DeptCode)

--parasitology
UNION all

Select
	ClinicalKey,
	AnimalID,
	date,
    projectId,
	'Parasitology' as category,
    'Fecal parasite exam' as servicerequested,
	Category as CategoryInt,
	s1.Value as category2,
	Technician as TechnicianId,
	LastName as LastName,
	FirstName as FirstName,
	Initials as Initials,
        s4.Value as Department,

	Specimen ,               ----- Specimen database table
	Method as methodInt,
	s2.Value as method,
	null as collectionMethod,
	null as tissue,
	null as remarks,

	cp.ts as rowversion,
	cp.objectid

From Cln_Parasitology cp
left join Sys_Parameters s1 on (s1.Flag = cp.Category And s1.Field = 'RequestCategory')
left join Sys_Parameters s2 on (s2.Flag = cp.Method And s2.Field = 'AnalysisMethodParasitol')
left join Sys_Parameters s3 on (s3.Flag = cp.Condition And s3.Field = 'AnimalConditionLab')
left join Ref_Technicians rt on (cp.Technician = rt.ID)
left join Sys_Parameters s4 on (s4.Flag = rt.DeptCode And s4.Field = 'DepartmentCode')

) t

left join Specimen sp on (sp.Value = t.Specimen)

where t.rowversion > ?