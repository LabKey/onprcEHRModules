Select 	
	cast(rtrim(ltrim(lower(Rpi.ProjectId))) as integer) as project,
	rtrim(ltrim(lower(cast(Rpi.IACUCCode as varchar)))) as protocol,
	Rpi.Title,



	Rpi.ProjectId as projectId,
	rp.IACUCCode as protocolId,
	pc.ProjectParentId,
	pc.ProjectChildID,
	Rpi.IACUCCode as projectCode,
	Rpi.StartDate,
	Rpi.EndDate,
	Rpi.IACUCApprovalDate,
	Rpi.OriginalApprovalDate,
	Rpi.USDALevel as USDALevelInt,
	s1.Value as USDALevel,
	Rpi.MultipleSurvivalSurg,
	Rpi.ProjectType as ProjectTypeInt,
	S2.Value as ProjectType,
	Rpi.Funded as FundedInt,
	S3.Value as Funded,
	Rpi.eIACUCNum,
	Rpi.IBCApprovalNum,
	Rpi.IBCApprovalRequired,
	Rpi.DateCreated,
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
	WHERE (pc.ProjectChildID is null or pc.ProjectChildID!=pc.ProjectParentID)

	AND rpi.ts > ?