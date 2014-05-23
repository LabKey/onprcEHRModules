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
	h.date,
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
  CASE
  when d.ResistanceFlag = 1 then 'Sensitive'
  when d.ResistanceFlag = 0 then 'Resistant'
  end as result,
	--d.ResistanceFlag as Resistant,

	d.ts as rowversion,
	d.objectid,
	
	case
	  WHEN rt.LastName = 'Unassigned' or rt.FirstName = 'Unassigned' THEN
        'Unassigned'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ', ' + rt.FirstName + ' (' + rt.Initials + ')'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 THEN
        rt.LastName + ', ' + rt.FirstName
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ' (' + rt.Initials + ')'
      WHEN datalength(rt.Initials) = 0 OR rt.initials = ' ' OR rt.lastname = ' none' THEN
        null
	  else
	   rt.Initials
    END as performedBy	,
    h.objectid as runid

FROM Cln_AntibioticSensData d
left join Cln_AntibioticSensHeader h on (d.ClinicalKey = h.ClinicalKey)
LEFT JOIN Ref_Technicians rt ON (rt.ID = h.Technician)
left join ref_snomed s1 on (s1.SnomedCode = h.Tissue)
left join ref_snomed s2 on (s2.SnomedCode = h.microbe)

where d.ts > ? or h.ts > ?