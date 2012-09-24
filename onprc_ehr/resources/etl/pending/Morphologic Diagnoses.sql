Select
	d.AutopsyID as procedureId,
	pa.objectid as parentid,
	TCode as code,                               ----- Ref_Snomed
	sno.Description as meaning,
	d.SnomedCodes,			----- Ref_Snomed
	sno2.Description as codeMeaing,
	SequenceNo,
	d.objectid ,
	d.ts as rowversion

From Path_AutopsyDiagnosis d
left join ref_snomed121311 sno on (sno.SnomedCode = TCode)
left join ref_snomed121311 sno2 on (sno2.SnomedCode = d.SnomedCodes)
left join Path_Autopsy pa on (d.AutopsyID = pa.AutopsyId)

UNION ALL

Select
	d.BiopsyId,
	pa.objectid as parentid,
	TCode as code,                               ----- Ref_Snomed
	sno.Description as meaning,
	d.SnomedCodes,			----- Ref_Snomed
	sno2.Description as codeMeaing,
	SequenceNo,
	d.objectid ,
	d.ts as rowversion

From Path_biopsyDiagnosis d
left join ref_snomed121311 sno on (sno.SnomedCode = TCode)
left join ref_snomed121311 sno2 on (sno2.SnomedCode = d.SnomedCodes)
left join Path_Biopsy pa on (d.BiopsyID = pa.BiopsyId)