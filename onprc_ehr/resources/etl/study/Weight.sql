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
	cast(AnimalID as nvarchar(4000)) as Id,
	Date as Date,
	WeightAmount as Weight,
	--TODO: why is this stored in weights?
	--TBFlag as  TBFlag ,           ----- TBFlag = 1 TB Test Intradermal   TBFlag = 2  TB Test Serological

	--NOTE: should not be necessary
	--CurrentFlag as CurrentFlag ,               ----- CurrentFlag = 1 Current Weight,  CurrentFlag = 2 Historical Weights information
	--IDKey as IDKey,

	af.objectid,
	af.ts as rowversion

From Af_Weights af
WHERE af.ts > ? and af.weightAmount != 0 and af.weightAmount is not null

--see death for final weights
UNION ALL

Select
	cast(AnimalID as nvarchar(4000)) as Id,
	Date as Date,
	WeightAtDeath as weight,
	afd.objectid,
	afd.ts as rowversion

From Af_Death AfD
WHERE afd.ts > ? and afd.WeightAtDeath > 0 AND afd.WeightAtDeath is not null

UNION ALL
  select
	cast(sg.AnimalID as nvarchar(4000)) as Id,
	sg.Date,
	sg.weight,
	sg.objectid,
	sg.ts as rowversion

From Sur_general sg
left join Af_Weights w
on (w.AnimalId = sg.AnimalID and w.Date = sg.Date and sg.Weight = w.WeightAmount)
WHERE sg.ts > ? and w.objectid IS NULL and sg.weight is not null and sg.weight > 0
