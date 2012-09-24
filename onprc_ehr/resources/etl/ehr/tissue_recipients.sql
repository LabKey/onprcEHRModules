Select
	TissueId,
	Recipient,						--Ref_TissueRecipients
	Organ,							--Ref_Snomed
	sno.Description,
	Affiliation as AffiliationInt,
	s1.Value as Affiliation,
	Sample as SampleInt,
	s2.Value as Sample,
	TissueKey,
	ptd.objectid,
	ptd.ts as rowversion

From Path_TissueDetails ptd
	left join Sys_Parameters s1 on (s1.Field = 'TissueAffiliation' and ptd.Affiliation = s1.Flag)
	left join Sys_Parameters s2 on (s2.Field = 'TissueSample' and ptd.Sample = s2.Flag)
	left join ref_snomed121311 sno on (sno.SnomedCode = ptd.organ)


