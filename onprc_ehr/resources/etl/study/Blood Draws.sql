Select 
	cast(AnimalID as varchar) as Id,
	Date as Date,
	--Reason as ReasonInt,
	Amount as quantity,
	DrawCount as needlesticks,
--	Investigator as Investigator  ,  ----- Ref_Investigator(InvestigatorID)
--		Ref.LastName as LastName,
--	IDKey as  IDKey, 

    --TODO
    s1.Value as Reason,

	CASE
		WHEN (afb.ts > bd.ts) THEN afb.ts
		ELSE bd.ts
	END as rowversion,
	bd.objectid,

	--blood data
	--bd.BloodIDKey as BloodIDkey,
	bd.ProjectId as Project,             ----- Ref_Projectsiacuc(ProjectID)

	bd.InvestigatorId as InvestigatorId,   ----- Ref_Investigator(InvestigatorID)
	ref.LastName + ', ' + ref.FirstName as requestor,
	bd.NoChargeFlag as NoChargeFlag,       ------When Not to be billed transaction Flag = 1, When it is to be billed Flag = 0
	bd.BloodDrawFlag as BloodDrawFlag      ------When Blood Draw transaction Flag = 1, When injections Flag = 0


From Af_Blood Afb
LEFT JOIN Sys_Parameters s1 ON (Afb.Reason = s1.Flag And s1.Field = 'BloodReason')
LEFT JOIN Ref_Investigator ref ON (Afb.Investigator = ref.InvestigatorID)

LEFT JOIN Af_BloodData bd ON (bd.BloodIDKey = afb.IDKey)
LEFT JOIN Ref_Projectsiacuc ref1 ON (ref1.ProjectID = bd.ProjectId)
LEFT JOIN Ref_Investigator ref2 ON (ref2.InvestigatorId = bd.InvestigatorId)

where afb.ts > ?