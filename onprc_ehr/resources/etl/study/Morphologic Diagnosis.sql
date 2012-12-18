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
Select
	cast(pa.AnimalID as nvarchar(4000)) as Id,
	pa.Date as date,
	pa.objectid as parentid,
	TCode as code,                               ----- Ref_Snomed
	sno.Description as codeMeaning,
	d.SnomedCodes as codes2,			----- Ref_Snomed
	sno2.Description as code2Meaing,
	--SequenceNo,
	d.objectid 
	--d.ts as rowversion

From Path_AutopsyDiagnosis d
left join ref_snomed121311 sno on (sno.SnomedCode = TCode)
left join ref_snomed121311 sno2 on (sno2.SnomedCode = d.SnomedCodes)
left join Path_Autopsy pa on (d.AutopsyID = pa.AutopsyId)

WHERE d.ts > ?

UNION ALL

Select
	cast(pa.AnimalID as nvarchar(4000)) as Id,
	pa.Date as date,
	pa.objectid as parentid,
	TCode as code,                               ----- Ref_Snomed
	sno.Description as codeMeaning,
	--TODO: handle multiple SNOMEDs
	d.SnomedCodes as code2,			----- Ref_Snomed
	sno2.Description as code2Meaing,
	--SequenceNo,
	d.objectid 
	--d.ts as rowversion

From Path_biopsyDiagnosis d
left join ref_snomed121311 sno on (sno.SnomedCode = TCode)
left join ref_snomed121311 sno2 on (sno2.SnomedCode = d.SnomedCodes)
left join Path_Biopsy pa on (d.BiopsyID = pa.BiopsyId)

WHERE d.ts > ?