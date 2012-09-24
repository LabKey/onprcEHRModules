Select
    'Necropsy' as type,
	pat.AutopsyID as AutopsyID ,
	pat.Organ as Organ,                 ----- Ref_SnomedLists
	sno.Description,
	pat.Preparation as PreparationInt,
	s1.Value as Preparation,
	pat.Weight as Weight,
	pat.WeightModifier as WeightModifierInt,
    s2.Value as Remark,
	pat.Appearance as AppearanceInt,
    s3.Value as Appearance,
	Pat.Displayorder as Displayorder,
	pa.objectid as parentid,

	pat.objectid,
	pat.ts as rowversion

From  Path_AutopsyWtsMaterials Pat
  left join Sys_Parameters s1 on (Pat.Preparation = s1.Flag And  s1.Field = 'AutopsyPreparation')
  left join Sys_Parameters s2 on (Pat.WeightModifier = s2.Flag And s2.Field = 'AutopsyWeightModifier')
  left join  Sys_Parameters s3 on (Pat.Appearance = s3.Flag And s3.Field = 'TissueAppearance')
  left join ref_snomed121311 sno ON (sno.SnomedCode = pat.Organ)
  left join Path_Autopsy pa ON (pa.AutopsyId = pat.AutopsyID)
where Weight = 0

union all

Select
   'Biopsy' as type,
	pat.BiopsyID as BiopsyID  ,
	Organ as Organ,				----- Ref_SnomedLists
	sno.Description as meaning,
	Preparation as PreparationInt,
	s1.Value as Preparation,
	Weight as Weight,
	WeightModifier as WeightModifierInt,
    s3.Value as Remark,
	Appearance as AppearanceInt,
    s2.Value as Appearance,
    null as displayorder,
    pa.objectid as parentid,

	pat.objectid,
	pat.ts as rowversion

From Path_BiopsyWtsMaterials Pat
	left join Sys_Parameters s1 on (Pat.Preparation = s1.Flag And  s1.Field = 'AutopsyPreparation')
	left join Sys_Parameters s2 on (Pat.Appearance = s2.Flag And s2.Field = 'TissueAppearance')
	left join sys_Parameters s3 on (Pat.WeightModifier = s3.Flag And s3.Field = 'AutopsyWeightModifier')
	left join ref_snomed121311 sno ON (sno.SnomedCode = pat.Organ)
	left join Path_biopsy pa ON (pa.BiopsyID = pat.BiopsyID)

where Weight = 0