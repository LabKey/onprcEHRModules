/*
Ref_FeesLease

Created by: W. Borum	Date: 8/17/2012

Tested by: 			Date:
      Raymond Blasa      8/21/2012

*/

Select
	rfl.ChargeCode,
	--rfl.agecategory,
	--s1.value,
	CASE
		WHEN rfl.AgeCategory = 1 THEN 0
		WHEN rfl.AgeCategory = 2 THEN 1
		WHEN rfl.AgeCategory = 3 THEN 4
		WHEN rfl.AgeCategory = 4 THEN 18

	END as minAge,
	CASE
		WHEN rfl.AgeCategory = 1 THEN 1
		WHEN rfl.AgeCategory = 2 THEN 4
		WHEN rfl.AgeCategory = 3 THEN 18
		WHEN rfl.AgeCategory = 4 THEN null
	END as maxAge,

	--rfl.ProcedureID,				--Ref_FeesProcedures
	--rf.ProcedureName,
	--rfl.AssignPool,					--Ref_Pool
	p1.Description as assignCondition,
	rfl.ReleasePool,				--Ref_Pool
	p2.Description as releaseCondition,
	rfl.BaseCharge,
	rfl.SetupFee,
	rfl.DateCreated,
	--rfl.DateDisabled,
	rfl.objectid

From Ref_FeesLease rfl
      left join Sys_Parameters s1 on (s1.Flag = rfl.AgeCategory and s1.Field = 'AgeCategory')
      left join Ref_FeesProcedures rf ON (rf.ProcedureID = rfl.procedureId)
      left join Ref_Pool p1 ON (p1.PoolCode = rfl.AssignPool)
      left join Ref_Pool p2 ON (p2.PoolCode = rfl.ReleasePool)

WHERE rfl.DateDisabled is null
