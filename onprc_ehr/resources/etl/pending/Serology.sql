SELECT
	ClinicalKey as ClinicalKey ,
	Tissue as Tissue ,		----- Ref_SnomedLists
	sno.Description,
	Agent as Agent ,
	sno2.description as agentMeaning,
	--Method as MethodInt  ,
	s2.Value as Method,
	CASE 
		WHEN Negative = 1 THEN 'Positive'
		WHEN Negative = 1 THEN 'Negative'
		else null
	END as qualResult,
	
    CASE 
    WHEN NULLIF(cln.Positive, '') IS NULL AND NULLIF(Remarks, '') IS NOT NULL THEN Remarks
    WHEN NULLIF(cln.Positive, '') IS NOT NULL AND NULLIF(Remarks, '') IS NULL THEN cln.Positive
    WHEN NULLIF(cln.Positive, '') IS NOT NULL AND NULLIF(Remarks, '') IS NOT NULL THEN cln.positive + '; ' + Remarks
    else null 
    END as Remark,

    cln.ts as rowversion,
    cln.objectid

FROM Cln_SerologyData cln
left join Sys_parameters s2 on (s2.Field = 'SerologyMethod' and s2.Flag = Method)
left join ref_snomed121311 sno ON (sno.SnomedCode = cln.Tissue)
left join ref_snomed121311 sno2 ON (sno2.SnomedCode = cln.Agent)
