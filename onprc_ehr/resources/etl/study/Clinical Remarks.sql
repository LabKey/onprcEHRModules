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
	cast(afc.AnimalID as varchar) as Id,
	date,

	labkey.core.GROUP_CONCAT_D(Afc.objectid, ';') as objectid,
	max(Afc.ts) as rowversion,
	afc.DiagnosisID,

	substring(labkey.core.GROUP_CONCAT_D(Remarks, ', '), 0, 3999) as remark
FROM (
SELECT
  --note: this is necessary for SQLServer to allow ORDER BY in the subquery
  top 99999999999999999
  dx.AnimalID,
  dx.Date,
  cr.objectid,
  cr.ts,
  dx.DiagnosisID,
  cr.Remarks

FROM Cln_DxRemarks cr
LEFT JOIN Cln_DX dx ON (cr.DiagnosisID = dx.DiagnosisID)

--TODO: account for all rowversions
--WHERE cr.ts > ?

ORDER BY dx.DiagnosisID, cr.SequenceNo

) afc

GROUP BY afc.AnimalID, afc.Date, afc.DiagnosisID

having max(afc.ts) > ?