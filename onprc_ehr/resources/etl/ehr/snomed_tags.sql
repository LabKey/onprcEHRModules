SELECT
	--cast(dx.AnimalID as nvarchar(4000)) as Id,
	--s.DiagnosisID ,
	dx.objectid as recordid,

	s.objectid,
	s2.i as sort,
	cast(s2.value as nvarchar(100)) as code

FROM Cln_DxSnomed s
left join cln_dx dx ON (dx.DiagnosisID = s.DiagnosisID)
cross apply dbo.fn_splitter(s.snomed, ',') s2
where s2.value is not null and s2.value != ''
and s.ts > ?

UNION ALL

SELECT
	--cast(dx.AnimalID as nvarchar(4000)) as Id,
	--s.DiagnosisID ,
	dx.objectid as recordid,

	s.objectid,
	s2.i as sort,
	cast(s2.value as nvarchar(100)) as code

FROM sur_snomed s
left join sur_general dx ON (dx.SurgeryId = s.SurgeryId)
cross apply dbo.fn_splitter(s.SnomedCodes, ',') s2
where s2.value is not null and s2.value != ''
and s.ts > ?

UNION ALL

Select
	pa.objectid as recordid,
	(cast(d.objectid as varchar(38)) + '_' + cast(s2.value as nvarchar(100))) as objectid,
	s2.i as sort,
	cast(s2.value as nvarchar(100)) as code

From Path_AutopsyDiagnosis d
left join ref_snomed sno on (sno.SnomedCode = TCode)
--left join ref_snomed sno2 on (sno2.SnomedCode = d.SnomedCodes)
left join Path_Autopsy pa on (d.AutopsyID = pa.AutopsyId)
cross apply dbo.fn_splitter(d.SnomedCodes, ',') s2
where s2.value is not null and s2.value != ''
and d.ts > ?

UNION ALL

Select
	d.objectid as recordid,
	(cast(d.objectid as varchar(38)) + '_' + cast(s2.value as nvarchar(100))) as objectid,
	s2.i as sort,
	cast(s2.value as nvarchar(100)) as code	

From Path_BiopsyDiagnosis d
left join Path_Biopsy pa on (d.BiopsyID = pa.BiopsyId)
cross apply dbo.fn_splitter(d.SnomedCodes, ',') s2
where s2.value is not null and s2.value != ''
and d.ts > ?