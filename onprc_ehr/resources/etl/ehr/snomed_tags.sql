SELECT
	dx.AnimalID,
	s.DiagnosisID ,
	dx.objectid as recordid,

	s.objectid,
	s2.i as number,
	s2.value as code

FROM Cln_DxSnomed s
left join cln_dx dx ON (dx.DiagnosisID = s.DiagnosisID)

cross apply dbo.fn_splitter(s.snomed, ',') s2

where s2.Code is not null and s2.Code != ''

and s.ts > ?