SELECT
	m.ClinicalKey as ClinicalKey  ,
	m.Bacteria  ,      ----- Ref_Snomedlists
	s.Description,
	m.Quantity ,
	m.Searchkey ,

	m.ts as rowversion,
	m.objectid

FROM Cln_MicrobiologyData m
left join ref_snomed121311 s ON (m.Bacteria = s.SnomedCode)