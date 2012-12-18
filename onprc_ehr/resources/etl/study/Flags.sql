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
--TODO: split this table between flags, notes and animal groups

Select
	cast(AnimalID as nvarchar(4000)) as Id,
	--p.PoolCode as PoolCode,    ----- Ref_Pool
	rp.ShortDescription AS category,
	rp.Description as flag,

	DateAssigned as date,
	DateReleased as enddate,
	--NOTE: redundant w/ enddate?
	--Status as  Status,            ---- flag = 1 Active pools, Flag = 0 Inactive Pools

	--p.ts as rowversion,
	p.objectid

From Af_Pool p
left join ref_pool rp ON (rp.PoolCode = p.PoolCode)

where p.ts > ?