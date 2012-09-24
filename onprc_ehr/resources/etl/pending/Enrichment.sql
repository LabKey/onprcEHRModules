Select
	IDKey as IDKey  ,
	cast(AnimalID as varchar) as Id,
	GivenDate as date,
	RemoveDate as enddate,
	t.ToyCode as ToyCode,      ------ Ref_Snomed
	toy.ToyType as type,
	s.SnomedCode as SNOMED,
	Reason as Reason,
	Remarks as Remarks,
	t.objectid,
	t.ts as rowversion

From Af_Toys t
left join ref_snomed121311 s ON (s.SnomedCode = t.ToyCode)

left join ref_toys toy ON (toy.ToyCode = t.ToyCode)