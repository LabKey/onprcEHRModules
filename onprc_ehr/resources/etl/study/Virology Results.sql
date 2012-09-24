SELECT
	ClinicalKey as ClinicalKey ,
	Tissue as source ,              ----- Ref_SnomedLists
	sno1.Description as sourceMeaning,
	Agent as virus ,		------ Ref_SnomedLists
	sno2.Description as virusMeaning,
	--Method as MethodInt ,
	s1.value as Method,
	--Negative as NegativeInt ,
        s2.Value as Result,
        
        
        
    CASE 
    WHEN NULLIF(cln.Positive, '') IS NULL AND NULLIF(Remarks, '') IS NOT NULL THEN Remarks
    WHEN NULLIF(cln.Positive, '') IS NOT NULL AND NULLIF(Remarks, '') IS NULL THEN cln.Positive
    WHEN NULLIF(cln.Positive, '') IS NOT NULL AND NULLIF(Remarks, '') IS NOT NULL THEN cln.positive + '; ' + Remarks
    else null 
    END as Remark,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_VirologyData cln
     left join Sys_parameters s1 on (s1.Flag = Method and s1.Field = 'VirologyMethod')
     left join Sys_Parameters s2 on (s2.Field = 'VirologyNegative' And s2.Flag = cln.Negative)
     left join ref_snomed121311 sno1 on (sno1.SnomedCode = cln.Tissue)
     left join ref_snomed121311 sno2 on (sno2.SnomedCode = cln.Agent)

where cln.ts > ?