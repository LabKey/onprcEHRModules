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

select
t.id,
t.date,
t.frequency,
--t.times,
CASE 
  WHEN t.enddate is null THEN t.alternateEnd
  WHEN t.alternateEnd is null then t.enddate
  WHEN t.alternateEnd < t.enddate THEN t.alternateEnd
  ELSE t.enddate
END as enddate,
t.code,
t.snomedMeaning,
t.amount,
t.amount_units,
t.route,
t.Reason,
t.performedBy,
t.category,
REPLACE(t.Remark, Char(21), Char(39)) as remark,
t.objectid
 
 
from (
SELECT
	cast(cln.AnimalId as nvarchar(4000)) as Id,
	Date,
	Medication as code,
	sno.Description as snomedMeaning,
	Dose as amount,

	s2.Value as amount_units,
	--Route as RouteInt ,
	s3.Value as Route,
	--Frequency as FrequencyInt ,
	(select rowid FROM labkey.ehr_lookups.treatment_frequency tf WHERe tf.meaning = s4.value) as frequency,
	
	--Duration as Duration,
	CASE
    WHEN enddate IS NULL THEN cast(DATEADD(minute, -1, DATEADD(day, 1+CASE WHEN duration = 0 THEN 1 ELSE duration END, cast(cast(date as date) AS datetime))) as datetime)
	  ELSE coalesce(EndDate, q.deathdate, q.departuredate)
    END as enddate,
    coalesce(q.deathdate, q.departuredate) as alternateEnd,

	--Reason as ReasonInt  ,
	s5.Value as Reason,
	--(select labkey.core.GROUP_CONCAT_DS(mt.medicationtime, ',', 1) as time FROM Cln_MedicationTimes mt where cln.SearchKey=mt.SearchKey) as times,
  CASE
    WHEN s6.value = 'Surgery' THEN 'Surgical'
    WHEN ss.code is not null THEN 'Clinical'
    ELSE 'Clinical'
  END as category,

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
    END as performedBy,

    Remarks as Remark,
	--cln.SearchKey as SearchKey,

	--cln.ts as rowversion,
	cln.objectid

FROM Cln_Medications cln
     left join  Ref_Technicians rt on (cln.Technician = rt.ID)
     left join Sys_parameters s2 on (s2.Field = 'MedicationUnits'and s2.Flag = Units)
     left join Sys_parameters s3 on (s3.Field = 'MedicationRoute'and s3.Flag = Route)
     left join Sys_parameters s4 on (s4.Field = 'MedicationFrequency' and s4.Flag = Frequency)
     left join Sys_parameters s5 on (s5.Field = 'MedicationReason' and s5.Flag = Reason)
     left join Sys_parameters s6 on (s6.Field = 'DepartmentCode' and s6.Flag = rt.DeptCode)
     left join labkey.ehr_lookups.snomed_subset_codes ss ON (ss.code = cln.medication AND ss.primaryCategory = 'Diet' and ss.container = (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC'))
     left join ref_snomed sno on (sno.SnomedCode = cln.Medication)
     left join Af_Qrf q on (q.animalid = cln.animalid)

where Medication is not null and Medication != '' 
AND (cln.ts > ?)

) t
