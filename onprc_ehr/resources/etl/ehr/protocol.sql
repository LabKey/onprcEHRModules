Select 	
	rtrim(ltrim(lower(Rpi.IACUCCode))) as protocol,
	rtrim(ltrim(Rpi.Title)) as title,
	--pi.InvestigatorID,
	--(i.LastName + ', ' + i.FirstName) as inves,
	Rpi.IACUCApprovalDate as aprove,
	Rpi.OriginalApprovalDate,
	Rpi.USDALevel as USDALevelInt,
	s1.Value as USDA_Level,
	Rpi.ProjectType as ProjectTypeInt,
	S2.Value as ProjectType,
	Rpi.eIACUCNum as external_id,
	Rpi.IBCApprovalNum as ibc_approval_name,
	Rpi.IBCApprovalRequired as ibc_approval_required,
	Rpi.DateCreated as created,

	Rpi.StartDate,
	Rpi.EndDate,

    --these are not current imported
	--lower(cast(Rpi.ProjectId as integer)) as project,
	rp.IACUCCode as protocolId,
	Rpi.IACUCCode as projectCode,
	Rpi.ProjectId as projectId,
	pc.ProjectParentId,
	pc.ProjectChildID,
	Rpi.MultipleSurvivalSurg,
	Rpi.Funded as FundedInt,
	S3.Value as Funded,
	Rpi.DateDisabled,
	rpi.objectid,
	rpi.ts as rowversion

From Ref_ProjectsIACUC rpi
	left join Sys_Parameters s1 on (s1.Field = 'USDALevel' and s1.Flag = rpi.USDALevel)
	left join Sys_Parameters s2 on (s2.Field = 'ProjectType' and s2.Flag = rpi.ProjectType)
	left join Sys_Parameters s3 on (s3.Field = 'IACUCFunding' and s3.Flag = rpi.Funded)
	--NOTE: this is designed to weed out inactive relationships
	left join (
        SELECT rp.* 
        from Ref_IACUCParentChildren rp
        JOIN (select 
            rp.ProjectChildID,
            MAX(ISNULL(DateDisabled, '2020-01-01')) As DateDisabled
            FROM Ref_IACUCParentChildren rp
            GROUP BY rp.ProjectChildID
        ) t ON (rp.ProjectChildId = t.ProjectChildID AND ISNULL(rp.DateDisabled, '2020-01-01') = t.DateDisabled)		
	) pc on (pc.ProjectChildID = rpi.ProjectID)
	left join Ref_ProjectsIACUC rp on (pc.ProjectParentID = rp.ProjectID)
	
	--left join Ref_ProjInvest pi on (pi.ProjectID = rpi.ProjectID AND pi.DateDisabled is null)
	--left join Ref_Investigator i on (pi.InvestigatorID = i.InvestigatorID and i.DateDisabled is null)
	
	
	WHERE (pc.ProjectChildID is null or pc.ProjectChildID = pc.ProjectParentID)
    AND rpi.ts > ?

  --TODO: this is a hack
  AND rpi.IACUCCode != '0579'