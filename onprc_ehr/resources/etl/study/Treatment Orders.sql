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
	cast(AnimalId as nvarchar(4000)) as Id,
	Date,
	Medication as code,
	sno.Description as snomedMeaning,
	Dose as Dose,
	--Units as UnitsInt ,
	s2.Value as Units,
	--Route as RouteInt ,
	s3.Value as Route,
	--Frequency as FrequencyInt ,
	--TODO: convert this
	--s4.Value as Frequency,
	Duration as Duration,
	EndDate as EndDate,
	--Reason as ReasonInt  ,
	s5.Value as Reason,

	--TODO
	--RenewalFlag as RenewalFlag ,

	case
	  WHEN rt.LastName = 'Unassigned' or rt.FirstName = 'Unassigned' THEN
        'Unassigned'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ', ' + rt.FirstName + ' (' + rt.Initials + ')'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 THEN
        rt.LastName + ', ' + rt.FirstName
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ' (' + rt.Initials + ')'
	  else
	   rt.Initials
    END as performedBy,

    Remarks as Remark,
	--cln.SearchKey as SearchKey,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_Medications cln
     left join  Ref_Technicians rt on (cln.Technician = rt.ID)
     left join Sys_parameters s2 on (s2.Field = 'MedicationUnits'and s2.Flag = Units)
     left join Sys_parameters s3 on (s3.Field = 'MedicationRoute'and s3.Flag = Route)
     left join Sys_parameters s4 on (s4.Field = 'MedicationFrequency' and s4.Flag = Frequency)
     left join Sys_parameters s5 on (s5.Field = 'MedicationReason' and s5.Flag = Reason)
     left join Sys_parameters s6 on (s6.Field = 'DepartmentCode' and s6.Flag = rt.DeptCode)
     left join ref_snomed sno on (sno.SnomedCode = cln.Medication)

where cln.ts > ? and Medication is not null and Medication != ''