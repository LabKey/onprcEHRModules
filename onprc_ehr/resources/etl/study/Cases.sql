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
	afc.CaseID as CaseID,
	cast(afc.AnimalID as varchar) as Id,
	OpenDate as date ,
	--Status as StatusInt ,
    --    s1.Value as Status,
	CloseDate as  CloseDate ,
	ReviewDate as ReviewDate ,
	--GroupCode as GroupCode,        ---- gCaseTypeConst: Clinical = 1, Surgery = 2, BehaviorCase = 3
	Case
		When GroupCode = 1 Then 'Clinical'
		When GroupCode = 2 Then 'Surgery'
		When GroupCode = 3 Then 'Behavior'
		When GroupCode = 4 Then 'Unknown'
	End AS Category,

	--TODO: what is this second table for (Af_CaseReviewData)?
--	af.Closing_Date as  Closing_Date ,
--	af.Review_Date as Review_Date ,
--	af.Date_Posted as  Date_Posted,

	Afc.objectid,
	Afc.ts as rowversion,
	
	--COUNT(dx.objectid) as dxCount,
	--COUNT(cr.objectid) as clinCount,
	
	labkey.core.GROUP_CONCAT_D(Remarks, ', ') as remark
FROM (	
SELECT
  --note: this is necessary for SQLServer to allow ORDER BY in the subquery
  top 99999999999999999	
  afc.AnimalID,
  afc.CaseID,
  afc.OpenDate,
  afc.CloseDate,
  afc.GroupCode,
  afc.ReviewDate,
  afc.objectid,
  afc.ts,
  cr.Remarks

From Af_Case afc
LEFT JOIN Sys_Parameters s1 ON (afc.Status = s1.Flag and s1.field = 'CaseStatus')
left join Cln_DX dx on (dx.CaseID = afc.CaseID and dx.Date = afc.OpenDate)
left join Cln_DxRemarks cr ON (cr.DiagnosisID = dx.DiagnosisID)
--LEFT JOIN Af_CaseReviewData af ON (af.CaseId = afc.CaseID)

--TODO: account for all rowversions
WHERE afc.ts > ?

ORDER BY afc.CaseID, cr.SequenceNo

) afc

GROUP BY afc.CaseID, afc.AnimalID, afc.OpenDate, afc.CloseDate, afc.ReviewDate, afc.GroupCode, afc.objectid, afc.ts