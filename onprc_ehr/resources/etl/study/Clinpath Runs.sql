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
	cast(Id as varchar) as Id,
	Date ,
	category as type,
	--CategoryInt ,
	Category2,
	--Technician As TechnicianID,
	--LastName as TechLastName,
	--FirstName as TechFirstName,
	--Initials as TechInitials,
    --    s4.Value as Department,
	Specimen as SpecimenId,            ---- information not required
	sp.Name as sampleType,
	sp.SNOMEDCODE as sampleSnomed,
	--MethodInt,
	Method,
	--ConditionInt,
	Condition,

    Tissue,
	remarks,


	Experimental ,     -------If selected Flag = 1 Else 0
	--PreAssignment as PreAssignment ,   -------If selected Flag = 1 Else 0
	--Quarantine as Quarantine ,       -------If selected Flag = 1 Else 0
	--Pregnant as Pregnant ,   	-------If selected Flag = 1 Else 0
	--Followup as Followup ,   	-------If selected Flag = 1 Else 0
	--Presale as Presale ,    	 -------If selected Flag = 1 Else 0
	--Fasting as Fasting ,     	 -------If selected Flag = 1 Else 0
	--Sedated as Sedated ,    	 ------ If selected Flag = 1 Else 0
    --ClinicalKey,

	case
	  WHEN TechLastName = 'Unassigned' or TechFirstName = 'Unassigned' THEN
        'Unassigned'
	  WHEN datalength(TechLastName) > 0 AND datalength(TechFirstName) > 0 AND datalength(TechInitials) > 0 THEN
        TechLastName + ', ' + TechFirstName + ' (' + TechInitials + ')'
	  WHEN datalength(TechLastName) > 0 AND datalength(TechFirstName) > 0 THEN
        TechLastName + ', ' + TechFirstName
	  WHEN datalength(TechLastName) > 0 AND datalength(TechInitials) > 0 THEN
        TechLastName + ' (' + TechInitials + ')'
	  else
	   TechInitials
    END as performedBy,

	t.rowversion,
	t.objectid

FROM (

--AntibioticSensitivity
SELECT
	ClinicalKey as ClinicalKey ,
	AnimalID as Id ,
	DATE as Date ,
	'Antibiotic Sensitivity' as category,
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
	Condition as ConditionInt  ,
	s3.Value as Condition,
	Experimental as Experimental ,     -------If selected Flag = 1 Else 0
	PreAssignment as PreAssignment ,   -------If selected Flag = 1 Else 0
	Quarantine as Quarantine ,       -------If selected Flag = 1 Else 0
	Pregnant as Pregnant ,   	-------If selected Flag = 1 Else 0
	Followup as Followup ,   	-------If selected Flag = 1 Else 0
	Presale as Presale ,    	 -------If selected Flag = 1 Else 0
	Fasting as Fasting ,     	 -------If selected Flag = 1 Else 0
	Sedated as Sedated ,    	 ------ If selected Flag = 1 Else 0
	null as Tissue,
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
	'Biochemistry' as category,
	Category as CategoryInt  ,
	s1.Value as Category2,
	Technician As TechnicianID,
	LastName as TechLastName,
	FirstName as TechFirstName,
	Initials as TechInitials,
        s4.Value as Department,

	Specimen as Specimen ,     --      Speciment database table
	Method as MethodInt  ,
	s2.Value as Method,

	Condition as ConditionInt  ,
	s3.Value as Condition,

	Experimental as Experimental  ,            	----- If selected Flag = 1, Else Flag = 0
	PreAssignment as PreAssignment  ,	        ----- If selected Flag = 1, Else Flag = 0
	Quarantine as Quarantine  ,			----- If selected Flag = 1, Else Flag = 0
	Pregnant as Pregnant  ,				----- If selected Flag = 1, Else Flag = 0
	Followup as Followup  ,				----- If selected Flag = 1, Else Flag = 0
	Presale as Presale  ,				----- If selected Flag = 1, Else Flag = 0
	Fasting as Fasting  ,				----- If selected Flag = 1, Else Flag = 0
	Sedated as Sedated  ,				----- If selected Flag = 1, Else Flag = 0
	--PanelFlag as PanelFlag ,
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
	'iSTAT' as category,
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

	Condition as ConditionInt  ,
	s3.Value as Condition,

	Experimental as Experimental ,		----- If selected Flag = 1, Else Flag = 0
	PreAssignment as PreAssignment  ,	----- If selected Flag = 1, Else Flag = 0
	Quarantine as Quarantine  ,		----- If selected Flag = 1, Else Flag = 0
	Pregnant as Pregnant ,			----- If selected Flag = 1, Else Flag = 0
	Followup as Followup ,			----- If selected Flag = 1, Else Flag = 0
	Presale as Presale ,			----- If selected Flag = 1, Else Flag = 0
	Fasting as Fasting ,			----- If selected Flag = 1, Else Flag = 0
	Sedated  as Sedated,			----- If selected Flag = 1, Else Flag = 0
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
	'Occult Blood' as category,
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

	Condition as ConditionInt  ,
	s3.Value as Condition,

	Experimental as Experimental ,
	PreAssignment as PreAssignment  ,
	Quarantine as Quarantine ,
	Pregnant as Pregnant ,
	Followup  as Followup,
	Presale as Presale ,
	Fasting as Fasting ,
	Sedated as Sedated ,
	--OccultFlag as OccultFlag ,
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
	'Hematology' as category,

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

	Condition as ConditionInt  ,
	s3.Value as Condition,

	Experimental as Experimental  ,       ----- If selected Flag = 1, Else Flag = 0
	PreAssignment as PreAssignment ,   ----- If selected Flag = 1, Else Flag = 0
	Quarantine as Quarantine ,         ----- If selected Flag = 1, Else Flag = 0
	Pregnant as Pregnant ,             ----- If selected Flag = 1, Else Flag = 0
	Followup  as Followup,             ----- If selected Flag = 1, Else Flag = 0
	Presale as Presale ,               ----- If selected Flag = 1, Else Flag = 0
	Fasting as Fasting ,		   ----- If selected Flag = 1, Else Flag = 0
	Sedated as Sedated ,		   ----- If selected Flag = 1, Else Flag = 0
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
	'Cerebral Spinal Fluid' as category,
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

	Condition as ConditionInt  ,
	s3.Value as Condition,

	Experimental as Experimental ,
	PreAssignment as PreAssignment ,
	Quarantine as Quarantine ,
	Pregnant as Pregnant ,
	Followup as Followup ,
	Presale as Presale ,
	Fasting as Fasting ,
	Sedated as Sedated ,
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
	'Microbiology' as category,
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

	Condition as ConditionInt  ,
	s3.Value as Condition,

	Experimental as Experimental   ,    		----- If selected Flag = 1, Else Flag = 0
	PreAssignment as PreAssignment  ,		----- If selected Flag = 1, Else Flag = 0
	Quarantine as Quarantine   ,			----- If selected Flag = 1, Else Flag = 0
	Pregnant as Pregnant  ,				----- If selected Flag = 1, Else Flag = 0
	Followup  as Followup    ,			----- If selected Flag = 1, Else Flag = 0
	Presale as Presale  ,				----- If selected Flag = 1, Else Flag = 0
	Fasting as Fasting  ,				----- If selected Flag = 1, Else Flag = 0
	Sedated as Sedated  ,				----- If selected Flag = 1, Else Flag = 0
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
	'Misc Tests' as category,
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

	Condition as ConditionInt  ,
	s3.Value as Condition,

	Experimental as Experimental ,
	PreAssignment as PreAssignment ,
	Quarantine as Quarantine ,
	Pregnant as Pregnant ,
	Followup as Followup  ,
	Presale as Presale ,
	Fasting as Fasting  ,
	Sedated as Sedated ,
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
	'Virology' as category,
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
	Condition as ConditionInt  ,
	s3.Value as Condition,
	Experimental as Experimental ,     ----- If selected Flag = 1 else Flag = 0
	PreAssignment as PreAssignment ,   ----- If selected Flag = 1 else Flag = 0
	Quarantine as Quarantine ,         ----- If selected Flag = 1 else Flag = 0
	Pregnant as Pregnant ,              ----- If selected Flag = 1 else Flag = 0
	Followup as Followup ,             ----- If selected Flag = 1 else Flag = 0
	Presale as Presale ,               ----- If selected Flag = 1 else Flag = 0
	Fasting as Fasting  ,              ----- If selected Flag = 1 else Flag = 0
	Sedated as Sedated,
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
	'Serology' as category,
	Category as CategoryInt  ,
	s1.Value as Category2,

	Technician As TechnicianID,
	LastName as TechLastName,
	FirstName as TechFirstName,
	Initials as TechInitials,
	--DeptCode as DepartmentCodeInt,
	s4.Value as DepartmentCode,

	Specimen as Specimen ,
	Method as MethodInt  ,
        s2.Value  as Method,

	Condition as ConditionInt  ,
	s3.Value as Condition,
	Experimental as Experimental  ,
	PreAssignment as PreAssignment ,
	Quarantine as Quarantine ,
	Pregnant as Pregnant,
	Followup as Followup ,
	Presale as Presale ,
	Fasting  as Fasting ,
	Sedated  as Sedated,
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
	'Urinalysis' as category,

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
	Condition as ConditionInt  ,
	s3.Value as Condition,
	Experimental as Experimental   ,
	PreAssignment as PreAssignment  ,
	Quarantine as Quarantine   ,
	Pregnant  as Pregnant,
	Followup as Followup  ,
	Presale as Presale  ,
	Fasting as Fasting  ,
	Sedated  as Sedated ,
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
--    left join Sys_parameters s5 on (s5.Field = 'UrineCollection' and s5.Flag = Collection)
--    left join Sys_parameters s6 on (s6.Field = 'UrineColor'and s6.Flag = Color)
--    left join Sys_parameters s7 on (s7.Field = 'BacteriaCount' and s7.Flag = Bacteria)
--    left join Sys_parameters s8 on (s8.Field = 'UrineMeasurement' and s8.Flag = Protein)
--    left join Sys_parameters s9 on (s9.Field = 'UrineMeasurement' and s9.Flag = Glucose)
--    left join Sys_parameters s10 on (s10.Field = 'UrineMeasurement' and s10.Flag = Ketone)
--    left join Sys_parameters s11 on (s11.Field = 'UrineMeasurement' and s11.Flag = Bilirubin)
--    left join Sys_parameters s12 on (s12.Field = 'UrineMeasurement' and s12.Flag = Blood)
--    left join Sys_parameters s13 on (s13.Field = 'Casts' and s13.Flag = CastsType1)
--    left join Sys_parameters s14 on (s14.Field = 'Casts' and s14.Flag = CastsType2)
   left join Sys_parameters s15 on (s15.Field = 'DepartmentCode' and s15.Flag = rt.DeptCode)


) t

left join Specimen sp on (sp.Value = t.Specimen)

where t.rowversion > ?