Select
	cast(AnimalID as varchar) as Id,
	af.ProjectID as Project,
	--RefProj.Title,

		-----    Ref_ProjectsIacuc (ProjectID)		
	AssignDate as Date,
	ReleaseDate as Enddate,

	--TODO
-- 	AssignPool as AssignPool  ,							--Ref_Pool
-- 	p1.ShortDescription as desc1,
-- 	EstimatedReleasePool,		--Ref_Pool
-- 	p1.ShortDescription as desc2,
-- 	ActualReleasePool,			--
-- 	p1.ShortDescription as desc3,
--NOTE: according to raymond replacementFlag is not in use and can be ignored
-- 	ReplacementFlag as ReplacementFlagRaw,
-- 	s1.Value as ReplacementFlag,

	IDKey as IDKey,

	af.objectid
	--af.ts as rowversion

From Af_Assignments af

LEFT JOIN Ref_ProjectsIacuc RefProj ON (RefProj.ProjectID = af.ProjectID)
LEFT JOIN Ref_Pool p1 ON (p1.PoolCode = AssignPool)
LEFT JOIN Ref_Pool p2 ON (p2.PoolCode = EstimatedReleasePool)
LEFT JOIN Ref_Pool p3 ON (p3.PoolCode = ActualReleasePool)
LEFT JOIN Sys_Parameters s1 ON (field = 'ReplacementFlag' and Flag = ReplacementFlag)

WHERE af.ts > ?