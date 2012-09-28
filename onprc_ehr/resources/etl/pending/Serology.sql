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
	ClinicalKey as ClinicalKey ,
	Tissue as Tissue ,		----- Ref_SnomedLists
	sno.Description,
	Agent as Agent ,
	sno2.description as agentMeaning,
	--Method as MethodInt  ,
	s2.Value as Method,
	CASE 
		WHEN Negative = 1 THEN 'Positive'
		WHEN Negative = 1 THEN 'Negative'
		else null
	END as qualResult,
	
    CASE 
    WHEN NULLIF(cln.Positive, '') IS NULL AND NULLIF(Remarks, '') IS NOT NULL THEN Remarks
    WHEN NULLIF(cln.Positive, '') IS NOT NULL AND NULLIF(Remarks, '') IS NULL THEN cln.Positive
    WHEN NULLIF(cln.Positive, '') IS NOT NULL AND NULLIF(Remarks, '') IS NOT NULL THEN cln.positive + '; ' + Remarks
    else null 
    END as Remark,

    cln.ts as rowversion,
    cln.objectid

FROM Cln_SerologyData cln
left join Sys_parameters s2 on (s2.Field = 'SerologyMethod' and s2.Flag = Method)
left join ref_snomed121311 sno ON (sno.SnomedCode = cln.Tissue)
left join ref_snomed121311 sno2 ON (sno2.SnomedCode = cln.Agent)
