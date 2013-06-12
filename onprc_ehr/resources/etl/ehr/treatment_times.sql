/*
 * Copyright (c) 2013 LabKey Corporation
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
  m.objectid as treatmentid,
  cln.objectid,
  cast(cln.MedicationTime as int) as time

FROM Cln_MedicationTimes cln
left join Cln_Medications m on (m.SearchKey = cln.SearchKey)

where m.AnimalId is not null and cln.medicationtime is not null
and (cln.ts > ? or m.ts > ?)
