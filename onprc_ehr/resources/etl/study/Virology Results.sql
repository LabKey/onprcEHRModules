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
	cast(h.AnimalID as nvarchar(4000)) as Id,
	h.DATE,
	
	Tissue as sampleType,              ----- Ref_SnomedLists
	sno1.Description as sampleMeaning,
	Agent as virusCode ,		------ Ref_SnomedLists
	sno2.Description as virusMeaning,
	--Method as MethodInt ,
	s1.value as Method,
	--Negative as NegativeInt ,
      s2.Value as Result,
        
    CASE 
    WHEN NULLIF(cln.Positive, '') IS NULL AND NULLIF(Remarks, '') IS NOT NULL THEN Remarks
    WHEN NULLIF(cln.Positive, '') IS NOT NULL AND NULLIF(Remarks, '') IS NULL THEN cln.Positive
    WHEN NULLIF(cln.Positive, '') IS NOT NULL AND NULLIF(Remarks, '') IS NOT NULL THEN cln.positive + '; ' + Remarks
    else null 
    END as Remark,

	cln.ts as rowversion,
	cln.objectid,
	h.objectid as runid

FROM Cln_VirologyData cln
     left join Sys_parameters s1 on (s1.Flag = Method and s1.Field = 'VirologyMethod')
     left join Sys_Parameters s2 on (s2.Field = 'VirologyNegative' And s2.Flag = cln.Negative)
     left join ref_snomed sno1 on (sno1.SnomedCode = cln.Tissue)
     left join ref_snomed sno2 on (sno2.SnomedCode = cln.Agent)
	 left join Cln_VirologyHeader h on (cln.ClinicalKey = h.ClinicalKey)
	
where cln.ts > ? or h.ts > ?