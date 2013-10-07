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
SELECT * FROM (
SELECT 
	cast(dx.AnimalID as nvarchar(4000)) as Id,
	dx.date,
	c.objectid as caseid,
	
	REPLACE(REPLACE(
	cast(coalesce(cln0.Remarks, '') as nvarchar(4000)) + 
	cast(coalesce(cln1.Remarks, '') as nvarchar(4000)) + 
	cast(coalesce(cln2.Remarks, '') as nvarchar(4000)) + 
	cast(coalesce(cln3.Remarks, '') as nvarchar(4000)) + 
	cast(coalesce(cln4.Remarks, '') as nvarchar(4000)) + 
	cast(coalesce(cln5.Remarks, '') as nvarchar(4000)) +
	cast(coalesce(cln6.Remarks, '') as nvarchar(4000))
	, char(25), '<>'), Char(21), Char(39)) AS remark,

  coalesce(cln0.objectid, cln1.objectid, cln2.objectid, cln3.objectid) as objectid,
	dx.objectid as parentid	,

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
	Case
		When c.GroupCode = 1 Then 'Clinical'
		When c.GroupCode = 2 Then 'Surgery'
		When c.GroupCode = 3 Then 'Behavior'
		When c.GroupCode = 4 Then 'Weight'
		Else null
	End AS Category

FROM Cln_Dx dx
left join Af_Case c ON (dx.CaseID = c.CaseID)
left join  Ref_Technicians rt on (dx.Technician = rt.ID)
left JOIN Cln_DxRemarks cln0 ON (dx.DiagnosisID = cln0.DiagnosisID AND cln0.SequenceNo = 0)
LEFT JOIN Cln_DxRemarks cln1 ON (dx.DiagnosisID = cln1.DiagnosisID AND cln1.SequenceNo = 1)
LEFT JOIN Cln_DxRemarks cln2 ON (dx.DiagnosisID = cln2.DiagnosisID AND cln2.SequenceNo = 2)
LEFT JOIN Cln_DxRemarks cln3 ON (dx.DiagnosisID = cln3.DiagnosisID AND cln3.SequenceNo = 3)
LEFT JOIN Cln_DxRemarks cln4 ON (dx.DiagnosisID = cln4.DiagnosisID AND cln4.SequenceNo = 4)
LEFT JOIN Cln_DxRemarks cln5 ON (dx.DiagnosisID = cln5.DiagnosisID AND cln5.SequenceNo = 5)
LEFT JOIN Cln_DxRemarks cln6 ON (dx.DiagnosisID = cln6.DiagnosisID AND cln6.SequenceNo = 6)

WHERE dx.DiagnosisID IN (select diagnosisid from Cln_DxRemarks r WHERE r.ts > ?)
) t
WHERE t.remark is not null and t.remark != ''