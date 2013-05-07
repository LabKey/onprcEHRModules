/*
 * Copyright (c) 2012-2013 LabKey Corporation
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
  t.category,

  t.specimen,
  t.name as specimenName,
  t.SNOMEDCODE as code,
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
		when OccultFlag =1 THEN 'Pos'
		else 'Neg'
	END as QualResult,
	Remarks as Remarks,
	cln.ts as rowversion,
	cln.ts as rowversion2,
	cln.objectid,
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
cp.objectid,
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
	cln.objectid,
	h.objectid as runid

FROM Cln_RareTestData cln
left join Ref_RareTests rt on (rt.RareTestID = cln.RareTestID)
left join Cln_RareTestHeader h on (h.ClinicalKey = cln.ClinicalKey)
left join Sys_Parameters s1 on (s1.Flag = h.Category And s1.Field = 'RequestCategory')
left join Sys_Parameters s2 on (s2.Flag = h.Method And s2.Field = 'AnalysisMethod')
left join Specimen sp on (sp.Value = h.Specimen)

--these will be in serology
where rt.RareTest != 'Interferon-Gamma Mycobacterium Testing (Primagam)'
) t

left join Ref_Technicians tech on (t.TechnicianId = tech.ID)


where (t.rowversion > ? or t.rowversion2 > ?)