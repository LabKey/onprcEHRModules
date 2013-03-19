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
	cast(dx.AnimalID as nvarchar(4000)) as Id,
	c.objectid as caseid,
	dx.objectid as recordid,

	cast(s.objectid as varchar(38)) + '_clndx' as objectid,
	coalesce(s.sequenceNo, 0) as set_number,
	s2.i as sort,
	cast(s2.value as nvarchar(100)) as code

FROM Cln_DxSnomed s
left join cln_dx dx ON (dx.DiagnosisID = s.DiagnosisID)
left join af_case c ON (dx.caseid = c.caseid)
cross apply dbo.fn_splitter(s.snomed, ',') s2
where s2.value is not null and s2.value != ''
and s.ts > ?

UNION ALL

SELECT
	cast(dx.AnimalID as nvarchar(4000)) as Id,
	null as caseid,
	dx.objectid as recordid,

	cast(s.objectid as varchar(38)) + '_surg' as objectid,
	s.Idkey as set_number,
	s2.i as sort,
	cast(s2.value as nvarchar(100)) as code

FROM sur_snomed s
left join sur_general dx ON (dx.SurgeryId = s.SurgeryId)
cross apply dbo.fn_splitter(s.SnomedCodes, ',') s2
where s2.value is not null and s2.value != ''
and s.ts > ?

UNION ALL

Select
	cast(pa.AnimalID as nvarchar(4000)) as Id,
	null as caseid,
	pa.objectid as recordid,
	(cast(d.objectid as varchar(38)) + '_' + cast(s2.value as nvarchar(100))) as objectid,
	coalesce(d.sequenceno, 0) as set_number,
	s2.i as sort,
	cast(s2.value as nvarchar(100)) as code

From Path_AutopsyDiagnosis d
left join ref_snomed sno on (sno.SnomedCode = TCode)
--left join ref_snomed sno2 on (sno2.SnomedCode = d.SnomedCodes)
left join Path_Autopsy pa on (d.AutopsyID = pa.AutopsyId)
cross apply dbo.fn_splitter(d.SnomedCodes, ',') s2
where s2.value is not null and s2.value != ''
and d.ts > ?

UNION ALL

Select
	cast(pa.AnimalID as nvarchar(4000)) as Id,
	null as caseid,
	d.objectid as recordid,
	(cast(d.objectid as varchar(38)) + '_' + cast(s2.value as nvarchar(100))) as objectid,
	coalesce(d.sequenceno, 0) as set_number,
	s2.i as sort,
	cast(s2.value as nvarchar(100)) as code	

From Path_BiopsyDiagnosis d
left join Path_Biopsy pa on (d.BiopsyID = pa.BiopsyId)
cross apply dbo.fn_splitter(d.SnomedCodes, ',') s2
where s2.value is not null and s2.value != ''
and d.ts > ?