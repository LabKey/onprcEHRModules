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
  t.Id,
  t.groupId,
  t.groupName,
  t.date,
  CASE
    WHEN (t.enddate IS NULL) THEN t.poolDisabledDate
    WHEN (t.poolDisabledDate IS NULL) THEN t.enddate
    WHEN (t.enddate < t.poolDisabledDate) THEN t.enddate
    ELSE t.poolDisabledDate
  END as enddate,
  t.objectid

FROM (
Select
	cast(p.AnimalID as nvarchar(4000)) as Id,
	(select rowid FROM labkey.ehr.animal_groups g where g.name = rp.description) as groupId,
	rp.Description as groupName,

	DateAssigned as date,
	coalesce(DateReleased, q.deathdate, q.departuredate) as enddate,
	rp.datedisabled as poolDisabledDate,
	p.objectid

From Af_Pool p
left join ref_pool rp ON (rp.PoolCode = p.PoolCode)
left join Af_Qrf q on (q.animalid = p.animalid)

where (p.ts > ? or q.ts > ? or rp.ts > ?) and rp.ShortDescription in ('CBG', 'EBG', 'HBG', 'PBG', 'STG', 'SBG', 'JBG', 'CCBG', 'CTG')

) t

