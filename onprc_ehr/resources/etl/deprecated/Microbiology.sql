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
	cast(mh.AnimalID as nvarchar(4000)) as Id,
	mh.DATE,
  mh.projectid as project,
	--m.ClinicalKey as ClinicalKey  ,
	m.Bacteria as organism,      ----- Ref_Snomedlists
	s.Description as organismMeaning,
	--m.Quantity,
	CASE
		WHEN Quantity = 5 THEN NULL
		else sp.value
	END as quantity,
	--m.Searchkey ,

	--m.ts as rowversion,
	m.objectid,
	mh.objectid as runId

FROM Cln_MicrobiologyData m
left join Cln_MicrobiologyHeader mh ON (m.ClinicalKey = mh.ClinicalKey)
left join ref_snomed s ON (m.Bacteria = s.SnomedCode)
left join sys_parameters sp ON (sp.field = 'Microbiologyquantity' and sp.flag = m.quantity)
--left join ref_snomed s2 ON (mh.tissue = s2.SnomedCode)

where m.ts > ? or mh.ts > ?