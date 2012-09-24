Select
	cast(AnimalID as varchar) as Id,
	Date as Date,
	WeightAmount as Weight,
	--TODO: why is this stored in weights?
	--TBFlag as  TBFlag ,           ----- TBFlag = 1 TB Test Intradermal   TBFlag = 2  TB Test Serological

	--NOTE: should not be necessary
	--CurrentFlag as CurrentFlag ,               ----- CurrentFlag = 1 Current Weight,  CurrentFlag = 2 Historical Weights information
	--IDKey as IDKey,

	af.objectid,
	af.ts as rowversion

From Af_Weights af
WHERE af.rowversion > ?

--see death for final weights
UNION ALL

Select
	cast(AnimalID as varchar) as Id,
	Date as Date,
	WeightAtDeath as weight,
	afd.objectid,
	afd.ts as rowversion

From Af_Death AfD
WHERE afd.rowversion > ?