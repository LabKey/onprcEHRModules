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
  cast(t.id as nvarchar(4000)) as Id,
  t.date,
  t.projectid as project,
  t.category,

  t.specimen,
  t.name as specimenName,
  t.Method,

  t.TestId,
  t.result,
  t.stringResults,
  t.qualResult,
  t.remarks as remark,

	case
	  WHEN tech.LastName = 'Unassigned' or tech.FirstName = 'Unassigned' THEN
        'Unassigned'
	  WHEN datalength(rtrim(tech.LastName)) > 0 AND datalength(rtrim(tech.FirstName)) > 0 AND datalength(tech.Initials) > 0 THEN
        tech.LastName + ', ' + tech.FirstName + ' (' + tech.Initials + ')'
	  WHEN datalength(rtrim(tech.LastName)) > 0 AND datalength(rtrim(tech.FirstName)) > 0 THEN
        tech.LastName + ', ' + tech.FirstName
	  WHEN datalength(rtrim(tech.LastName)) > 0 AND datalength(tech.Initials) > 0 THEN
        tech.LastName + ' (' + tech.Initials + ')'
      WHEN datalength(tech.Initials) = 0 OR tech.initials = ' ' OR tech.lastname = ' none' THEN
        null
	  else
	   tech.Initials
    END as performedBy,

  t.runid,
  t.objectid,
  t.rowversion


from (

--occult blood

SELECT
	ClinicalKey as ClinicalKey ,
	AnimalID as Id ,
	Date as Date ,
  projectid,
	Category as CategoryInt  ,
	s1.Value as Category,

	Technician As TechnicianID,

	Specimen as Specimen ,			----- Specimen database table
	sp.name,
	sp.SNOMEDCODE,
	Method as MethodInt  ,
	s2.Value as Method,

	'Occult Blood' as TestId,
	--OccultFlag as OccultFlag ,
	null as result,
	null as stringResults,
	CASE
		when OccultFlag =1 THEN 'Positive'
		else 'Negative'
	END as QualResult,
	Remarks as Remarks,
	cln.ts as rowversion,
	cln.ts as rowversion2,
  cast(cln.objectid as varchar(38)) as objectid,
	null as runid

FROM Cln_OccultBlood cln
     left join Sys_Parameters s1 on (s1.Flag = Cln.Category And s1.Field = 'RequestCategory')
     left join Sys_Parameters s2 on (s2.Flag = Cln.Method And s2.Field = 'AnalysisMethod')
     left join Specimen sp on (sp.Value = cln.Specimen)

--occult blood from parasitology table
UNION ALL

select 
null as clinicalKey,
cp.AnimalID,
cp.DATE,
cp.projectid,
cp.Category as categoryInt,
null as category,
cp.Technician as technicianId,

cp.Specimen,
sp.name,
sp.SNOMEDCODE,
cp.Method as methodInt,
s2.Value as Method,

'Occult Blood' as TestId,
null as result,
null as stringResults,
s5.Value as qualResult,
--cp.OccultBlood,
null as remark,
cp.ts as rowversion,
cp.ts as rowversion2,
cast(cp.objectid as varchar(38)) as objectid,
null as runid
 
from Cln_Parasitology cp
left join Sys_Parameters s5 on (s5.Flag = cp.OccultBlood And s5.Field = 'occultblood')
left join Sys_Parameters s1 on (s1.Flag = cp.Category And s1.Field = 'RequestCategory')
left join Sys_Parameters s2 on (s2.Flag = cp.Method And s2.Field = 'AnalysisMethod')
left join Specimen sp on (sp.Value = cp.Specimen)

where OccultBlood != -1

UNION ALL

--misc tests:

SELECT
	cln.ClinicalKey as ClinicalKey ,
	h.AnimalID,
	h.DATE,
  projectid,
	h.Category as CategoryInt,
	s1.Value as category,
	h.Technician as technicianId,

	h.Specimen,
	sp.Name,
	coalesce(sp.SNOMEDCODE, h.tissue) as code,
	h.Method as MethodInt,
	s2.Value as Method,

	--cln.RareTestID as RareTestID ,    ----- Ref_RareTests
	rt.RareTest as TestId,

	null as result,
	cln.Value as stringResults ,
	null as qualResult,
	cln.Remarks as Remarks,
	cln.ts as rowversion,
	h.ts as rowversion2,
  cast(cln.objectid as varchar(38)) as objectid,
	h.objectid as runid

FROM Cln_RareTestData cln
left join Ref_RareTests rt on (rt.RareTestID = cln.RareTestID)
left join Cln_RareTestHeader h on (h.ClinicalKey = cln.ClinicalKey)
left join Sys_Parameters s1 on (s1.Flag = h.Category And s1.Field = 'RequestCategory')
left join Sys_Parameters s2 on (s2.Flag = h.Method And s2.Field = 'AnalysisMethod')
left join Specimen sp on (sp.Value = h.Specimen)

--these will be in serology
where rt.RareTest != 'Interferon-Gamma Mycobacterium Testing (Primagam)'

--CSF
UNION ALL

SELECT
  ClinicalKey ,
  AnimalID as Id  ,
  DATE ,
  null as projectId,
  null as categoryInt,
  null as category,
  cln.Technician as technicianId,

  Specimen as Specimen ,     --      Specimen database table
  sp.name,
  sp.snomedcode,
  null as MethodInt,
  null as Method  ,
  'CSF WBC' as TestId,
  TotalWBC as Result,
  null as stringResults,
  null as qual_result,
  remarks ,
  cln.ts as rowversion,
  null as rowversion2,
  (cast(cln.objectid as varchar(38)) + '_WBC') as objectid,
  null as runid

FROM Cln_CerebralspinalFluid cln
left join Specimen sp on (sp.Value = cln.Specimen)
WHERE cln.TotalWBC != -1 AND cln.TotalWBC is not null

UNION ALL

SELECT
  ClinicalKey ,
  AnimalID as Id  ,
  DATE ,
  null as projectId,
  null as categoryInt,
  null as category,
  cln.Technician as technicianId,

  Specimen as Specimen ,     --      Specimen database table
  sp.name,
  sp.snomedcode,
  null as MethodInt,
  null as Method  ,
  'CSF Neut' as TestId,
  WBCNeurophils as Result,
  null as stringResults,
  null as qual_result,
  remarks ,
  cln.ts as rowversion,
  null as rowversion2,
  (cast(cln.objectid as varchar(38)) + '_Neut') as objectid,
  null as runid

FROM Cln_CerebralspinalFluid cln
left join Specimen sp on (sp.Value = cln.Specimen)
WHERE cln.WBCNeurophils != -1 AND cln.WBCNeurophils is not null

UNION ALL

SELECT
  ClinicalKey ,
  AnimalID as Id  ,
  DATE ,
  null as projectId,
  null as categoryInt,
  null as category,
  cln.Technician as technicianId,

  Specimen as Specimen ,     --      Specimen database table
  sp.name,
  sp.snomedcode,
  null as MethodInt,
  null as Method  ,
  'CSF Lymph' as TestId,
  WBCLymphocytes as Result,
  null as stringResults,
  null as qual_result,
  remarks ,
  cln.ts as rowversion,
  null as rowversion2,
  (cast(cln.objectid as varchar(38)) + '_Lymph') as objectid,
  null as runid

FROM Cln_CerebralspinalFluid cln
left join Specimen sp on (sp.Value = cln.Specimen)
WHERE cln.WBCLymphocytes != -1 AND cln.WBCLymphocytes is not null

UNION ALL

SELECT
  ClinicalKey ,
  AnimalID as Id  ,
  DATE ,
  null as projectId,
  null as categoryInt,
  null as category,
  cln.Technician as technicianId,

  Specimen as Specimen ,     --      Specimen database table
  sp.name,
  sp.snomedcode,
  null as MethodInt,
  null as Method  ,
  'CSF Total Protein' as TestId,
  TotalProtein as Result,
  null as stringResults,
  null as qual_result,
  remarks ,
  cln.ts as rowversion,
  null as rowversion2,
  (cast(cln.objectid as varchar(38)) + '_TP') as objectid,
  null as runid

FROM Cln_CerebralspinalFluid cln
left join Specimen sp on (sp.Value = cln.Specimen)
WHERE cln.TotalProtein != -1 AND cln.TotalProtein is not null

UNION ALL

SELECT
  ClinicalKey ,
  AnimalID as Id  ,
  DATE ,
  null as projectId,
  null as categoryInt,
  null as category,
  cln.Technician as technicianId,

  Specimen as Specimen ,     --      Specimen database table
  sp.name,
  sp.snomedcode,
  null as MethodInt,
  null as Method  ,
  'CSF Glucose' as TestId,
  Glucose as Result,
  null as stringResults,
  null as qual_result,
  remarks ,
  cln.ts as rowversion,
  null as rowversion2,
  (cast(cln.objectid as varchar(38)) + '_Gluc') as objectid,
  null as runid

FROM Cln_CerebralspinalFluid cln
left join Specimen sp on (sp.Value = cln.Specimen)
WHERE cln.Glucose != -1 AND cln.Glucose is not null

) t

left join Ref_Technicians tech on (t.TechnicianId = tech.ID)


where (t.rowversion > ? or t.rowversion2 > ?)