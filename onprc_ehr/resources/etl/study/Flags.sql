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

Select
	cast(p.AnimalID as nvarchar(4000)) as Id,
	--p.PoolCode as PoolCode,    ----- Ref_Pool
	rtrim(ltrim(rp.ShortDescription)) AS flag,
	rtrim(ltrim(rp.ShortDescription)) AS category,
	rp.Description as value,

	DateAssigned as date,
--	DateReleased as enddate,

	coalesce(DateReleased, q.deathdate, q.departuredate, rp.datedisabled) as enddate ,

	--NOTE: redundant w/ enddate?
	--Status as  Status,            ---- flag = 1 Active pools, Flag = 0 Inactive Pools

	--p.ts as rowversion,
	cast(p.objectid as varchar(38)) as objectid

From Af_Pool p
left join ref_pool rp ON (rp.PoolCode = p.PoolCode)
left join Af_Qrf q on (q.animalid = p.animalid)

where (p.ts > ? or q.ts > ? or rp.ts > ?) and rp.ShortDescription not in ('CBG', 'EBG', 'HBG', 'PBG', 'STG', 'SBG', 'JBG', 'Origin')

UNION ALL

select

r.animalid as Id,
null as flag,
'Genetics' as category,
'Sample sent for parentage' as value,
r.DateProcessed as date,
coalesce(q.deathdate, q.departuredate) as enddate,
(cast(r.objectid as varchar(38)) + '_parentage') as objectid

from Res_DNABank r
join Af_Qrf q on (cast(q.AnimalID as nvarchar(4000)) = r.animalid)

where r.DateProcessed is not null
--exclude non-center animals
and r.animalid not like '%n' and r.animalid not like '%f'
and (r.ts > ? or q.ts > ?)

UNION ALL

select

  r.animalid as Id,
  null as flag,
  'Genetics' as category,
  'Blood drawn for DNA Bank' as value,
  r.DateProcessed as date,
  coalesce(q.deathdate, q.departuredate) as enddate,
  (cast(r.objectid as varchar(38)) + '_dna') as objectid

from Res_DNABank r
  join Af_Qrf q on (cast(q.AnimalID as nvarchar(4000)) = r.animalid)
  left join Sys_Parameters s ON (r.Project = s.Flag AND s.Field = 'DNAProject')

where r.DateProcessed is not null
      --exclude non-center animals
      and (r.animalid not like '%n' and r.animalid not like '%f')
      and s.Value = 'DNA Bank'
      and (r.ts > ? or q.ts > ?)
