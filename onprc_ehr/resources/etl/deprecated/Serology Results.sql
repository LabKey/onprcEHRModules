/*
 * Copyright (c) 2012-2014 LabKey Corporation
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
	cast(h.AnimalID as nvarchar(4000)) as Id,
	h.DATE,
	'Virology' as category,
	
	tissue,              ----- Ref_SnomedLists
	sno1.Description as tissueMeaning,
	agent,		------ Ref_SnomedLists
	sno2.Description as agentMeaning,
	--Method as MethodInt ,
	s1.value as Method,
	--Negative as NegativeInt ,
    null as numericResult,
    null as units,
    s2.value as result,
    cln.Positive as qualifier,
        
    cln.Remarks as Remark,

	--cln.ts as rowversion,
	cln.objectid,
	h.objectid as runid

FROM Cln_VirologyData cln
     left join Sys_parameters s1 on (s1.Flag = Method and s1.Field = 'VirologyMethod')
     left join Sys_Parameters s2 on (s2.Field = 'VirologyNegative' And s2.Flag = cln.Negative)
     left join ref_snomed sno1 on (sno1.SnomedCode = cln.Tissue)
     left join ref_snomed sno2 on (sno2.SnomedCode = cln.Agent)
	 left join Cln_VirologyHeader h on (cln.ClinicalKey = h.ClinicalKey)
	
where cln.ts > ? or h.ts > ?

UNION ALL

SELECT
	cast(sh.AnimalID as nvarchar(4000)) as Id,
	sh.DATE,
	'Serology' as category,

	Tissue as Tissue ,		----- Ref_SnomedLists
	sno.Description as tissueMeaning,
	agent,
	sno2.description as agentMeaning,
	s2.Value as method,

    null as numericresult,
    null as units,
	--at least let this field show whether it's positive or not
	CASE
		WHEN Negative = 0 THEN 'Positive'
		WHEN Negative = 1 THEN 'Negative'
		WHEN Negative = 3 THEN 'Indeterminate'
		else null
	END as result,
	rtrim(positive) as qualifier,

    Remarks as remark,

    --cln.ts as rowversion,
    cln.objectid,
    sh.objectid as runId

FROM Cln_SerologyData cln
left join Cln_SerologyHeader sh on (cln.ClinicalKey = sh.ClinicalKey)
left join Sys_parameters s2 on (s2.Field = 'SerologyMethod' and s2.Flag = cln.Method)
left join ref_snomed sno ON (sno.SnomedCode = cln.Tissue)
left join ref_snomed sno2 ON (sno2.SnomedCode = cln.Agent)

WHERE cln.ts > ? or sh.ts > ?

UNION ALL

SELECT
	h.AnimalID,
	h.DATE,
	'Serology' as category,
	--s1.Value as category2,

	h.Tissue,
	sno.Description as tissueMeaning,
	'E-20010' as agent,
	null as agentMeaning,
	rt.RareTest as method,

	null as numericresult,
	null as units,
	CASE WHEN cln.Value like 'Negative' THEN 'Negative' ELSE cln.value END as Result,
	null as qualifier,

	cln.Remarks as Remark,
	cln.objectid,
	rt.objectid as runid

FROM Cln_RareTestData cln
left join Ref_RareTests rt on (rt.RareTestID = cln.RareTestID)
left join Cln_RareTestHeader h on (h.ClinicalKey = cln.ClinicalKey)
left join Sys_Parameters s1 on (s1.Flag = h.Category And s1.Field = 'RequestCategory')
left join Sys_Parameters s2 on (s2.Flag = h.Method And s2.Field = 'AnalysisMethod')
left join Ref_SnoMed sno on (h.Tissue = sno.SnomedCode)
left join Specimen sp on (sp.Value = h.Specimen)

where rt.RareTest = 'Interferon-Gamma Mycobacterium Testing (Primagam)'
AND (cln.ts > ? OR rt.ts > ? OR h.ts > ?)