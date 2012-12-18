SELECT
	--cast(dx.AnimalID as nvarchar(4000)) as Id,
	--s.DiagnosisID ,
	dx.objectid as recordid,

	s.objectid,
	s2.i as sort,
	s2.value as code

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
	s2.value as code

FROM sur_snomed s
left join sur_general dx ON (dx.SurgeryId = s.SurgeryId)
cross apply dbo.fn_splitter(s.SnomedCodes, ',') s2
where s2.value is not null and s2.value != ''
and s.ts > ?
  