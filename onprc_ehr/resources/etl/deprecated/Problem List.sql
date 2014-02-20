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
/*
MasterProblemList

Created by: Lakshmi Kolli	Date: 8/16/2012

Tested by: 			Date:
          Raymond Blasa             8/21/2012

*/

 SELECT
	cast(ml.AnimalID as nvarchar(4000)) as Id,
	ML.DateCreated as date,

	CASE
	  WHEN c.CloseDate < ml.DateDisabled THEN coalesce(c.CloseDate, q.deathdate, q.departuredate)
      ELSE coalesce(ML.DateDisabled, q.deathdate, q.departuredate)
    END as enddate,
	
	null as parentid,
	c.objectid as caseid,
	s1.Value as category,
	ml.objectid

FROM MasterProblemList ML
left join Af_Case c on (c.CaseID = ml.CaseID)
LEFT JOIN Sys_parameters s1 ON (s1.Field = 'MasterProblemList' and s1.Flag = MasterProblem)
left join Af_Qrf q on (q.animalid = ml.animalid)

WHERE (ml.ts > ? or q.ts > ? OR c.ts > ?)
