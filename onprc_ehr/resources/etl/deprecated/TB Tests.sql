/*
 * Copyright (c) 2013-2014 LabKey Corporation
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
  cast(w.AnimalID as nvarchar(4000)) as Id,
  w.date,
  (cast(w.objectid as varchar(38)) + '_tb') as objectid

FROM af_weights w
where w.tbflag = 1 and w.ts > ?

UNION ALL

SELECT
  dx.AnimalID,
  dx.Date,
  cast(sno.objectid as varchar(36)) as objectid

FROM Cln_DXSnomed sno
  LEFT JOIN Cln_DX dx ON (sno.DiagnosisID = dx.DiagnosisID)
  LEFT JOIN af_weights w2 ON (w2.AnimalId = dx.AnimalID AND w2.Date = dx.Date and w2.TBFlag = 1)

WHERE sno.Snomed = 'P-54268' AND w2.AnimalId IS NULL and sno.ts > ?