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
	cast(sh.AnimalID as nvarchar(4000)) as Id,
	sh.DATE,
	Tissue as Tissue ,		----- Ref_SnomedLists
	sno.Description as tissueMeaning,
	agent,
	sno2.description as agentMeaning,
	s2.Value as method,
	
	--at least let this field show whether it's positive or not
	CASE 
		WHEN Negative = 0 THEN 'POS'
		WHEN Negative = 1 THEN 'NEG'
		else null
	END as qualResult,
	
    CASE 
      WHEN positive IS NOT NULL AND len(rtrim(positive)) > 0 THEN positive + '\n' + remarks
      else Remarks 
    END as remark,

    --cln.ts as rowversion,
    cln.objectid,
    sh.objectid as runId

FROM Cln_SerologyData cln
left join Cln_SerologyHeader sh on (cln.ClinicalKey = sh.ClinicalKey)
left join Sys_parameters s2 on (s2.Field = 'SerologyMethod' and s2.Flag = cln.Method)
left join ref_snomed sno ON (sno.SnomedCode = cln.Tissue)
left join ref_snomed sno2 ON (sno2.SnomedCode = cln.Agent)

WHERE cln.ts > ? or sh.ts > ?