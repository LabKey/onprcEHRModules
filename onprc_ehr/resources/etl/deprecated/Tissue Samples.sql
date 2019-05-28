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
Select
	cast(pa.AnimalID as nvarchar(4000)) as Id,
	pa.date as date,
    'Necropsy' as type,
	pat.objectid as parentId,
	pat.Organ as tissue,                 ----- Ref_SnomedLists
	sno.Description as tissueMeaning,
	
	--pat.Preparation as PreparationInt,
	s1.Value as Preparation,
	pat.Weight as Weight,
	--pat.WeightModifier as WeightModifierInt,
    s2.Value as tissueCondition,
	--pat.Appearance as AppearanceInt,
    s3.Value as remark,
	--Pat.Displayorder as Displayorder,
	--pa.objectid as parentid,

	pat.objectid
	--pat.ts as rowversion

From  Path_AutopsyWtsMaterials Pat
  left join Sys_Parameters s1 on (Pat.Preparation = s1.Flag And  s1.Field = 'AutopsyPreparation')
  left join Sys_Parameters s2 on (Pat.WeightModifier = s2.Flag And s2.Field = 'AutopsyWeightModifier')
  left join  Sys_Parameters s3 on (Pat.Appearance = s3.Flag And s3.Field = 'TissueAppearance')
  left join ref_snomed sno ON (sno.SnomedCode = pat.Organ)
  left join Path_Autopsy pa ON (pa.AutopsyId = pat.AutopsyID)
where (pat.ts > ? or pa.ts > ?)

union all

Select
   	cast(pa.AnimalID as nvarchar(4000)) as Id,
	pa.date as date,
   'Biopsy' as type,
   pa.objectid as parentid,

	Organ as tissue,				----- Ref_SnomedLists
	sno.Description as tissueMeaning,
	--Preparation as PreparationInt,
	s1.Value as Preparation,
	
	Weight as Weight,
	--WeightModifier as WeightModifierInt,
    s2.Value as tissueCondition,
	--Appearance as AppearanceInt,
    s3.Value as remark,
    --null as displayorder,
    
	pat.objectid
	--pat.ts as rowversion

From Path_BiopsyWtsMaterials Pat
	left join Sys_Parameters s1 on (Pat.Preparation = s1.Flag And  s1.Field = 'AutopsyPreparation')
	left join Sys_Parameters s2 on (Pat.Appearance = s2.Flag And s2.Field = 'TissueAppearance')
	left join sys_Parameters s3 on (Pat.WeightModifier = s3.Flag And s3.Field = 'AutopsyWeightModifier')
	left join ref_snomed sno ON (sno.SnomedCode = pat.Organ)
	left join Path_biopsy pa ON (pa.BiopsyID = pat.BiopsyID)

where (pat.ts > ? or pa.ts > ?)