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
	cast(AnimalID as nvarchar(4000)) as Id,
	Date as Date,
    'N/A' as area,
	'Menses' as category,
    'M' as observation,
	case
	  WHEN rt.LastName = 'Unassigned' or rt.FirstName = 'Unassigned' or rt.LastName = ' none' THEN
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

  cast(bm.objectid as varchar(38)) as objectid

FROM Brd_Menstruations bm

LEFT JOIN Ref_Technicians rt ON (bm.Technician = rt.ID)
LEFT JOIN Sys_parameters s1 ON (s1.Field = 'DepartmentCode' and s1.Flag = rt.DeptCode)

where bm.ts > ?

UNION ALL

SELECT
  cast(dx.AnimalID as nvarchar(4000)) as Id,
  dx.date,
  'N/A' as area,
  CASE
    WHEN s2.value ='F-YY002' THEN 'BCS'
    WHEN s2.value ='F-YY003' THEN 'BCS'
    WHEN s2.value ='F-YY004' THEN 'BCS'
    WHEN s2.value ='F-YY005' THEN 'BCS'
    WHEN s2.value ='F-YY006' THEN 'BCS'
    WHEN s2.value ='F-Y3712' THEN 'Alopecia Score'
    WHEN s2.value ='F-Y3714' THEN 'Alopecia Score'
    WHEN s2.value ='F-Y3716' THEN 'Alopecia Score'
    WHEN s2.value ='F-Y3718' THEN 'Alopecia Score'
    WHEN s2.value ='F-Y3720' THEN 'Alopecia Score'
    WHEN s2.value ='F-Y3722' THEN 'Alopecia Score'
  END as category,
  CASE
    WHEN s2.value ='F-YY002' THEN '1'
    WHEN s2.value ='F-YY003' THEN '2'
    WHEN s2.value ='F-YY004' THEN '3'
    WHEN s2.value ='F-YY005' THEN '4'
    WHEN s2.value ='F-YY006' THEN '5'
    WHEN s2.value ='F-Y3712' THEN '0'
    WHEN s2.value ='F-Y3714' THEN '1'
    WHEN s2.value ='F-Y3716' THEN '2'
    WHEN s2.value ='F-Y3718' THEN '3'
    WHEN s2.value ='F-Y3720' THEN '4'
    WHEN s2.value ='F-Y3722' THEN '5'
  END as observation,
  null as performedby,
  cast(s.objectid as varchar(38)) + '-' + cast(s2.i as varchar(100)) + '-' + cast(s2.value as nvarchar(100)) as objectid

FROM Cln_DxSnomed s
  left join cln_dx dx ON (dx.DiagnosisID = s.DiagnosisID)
  left join af_case c ON (dx.caseid = c.caseid)
  cross apply dbo.fn_splitter(s.snomed, ',') s2
where s2.value is not null and s2.value IN (
  'F-YY002',
  'F-YY003',
  'F-YY004',
  'F-YY005',
  'F-YY006',
  'F-Y3712',
  'F-Y3714',
  'F-Y3716',
  'F-Y3718',
  'F-Y3720',
  'F-Y3722'
)
and s.ts > ?