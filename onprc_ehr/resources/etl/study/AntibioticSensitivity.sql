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
	cast(h.AnimalID as varchar) as Id,
	h.date,
	h.Tissue,
	s1.Description as TissueMeaning,
	h.Microbe,
	s2.Description as MicrobeMeaning,
	
	--d.ClinicalKey  as ClinicalKey,
	d.Antibiotic as Antibiotic ,
	
	-- original usage: Flag = 0 Resistant to Antibiotics, Flag = 1 not Resistant to Antibiotics
	-- converted to the reverse
	CASE
	when d.ResistanceFlag = 1 then 0
	when d.ResistanceFlag = 0 then 1
	end as Resistant,
	--d.ResistanceFlag as Resistant,

	d.ts as rowversion,
	d.objectid

FROM Cln_AntibioticSensData d
left join Cln_AntibioticSensHeader h on (d.ClinicalKey = h.ClinicalKey)
left join ref_snomed121311 s1 on (s1.SnomedCode = h.Tissue)
left join ref_snomed121311 s2 on (s2.SnomedCode = h.microbe)

where d.ts > ?