--TODO: many of these should not be stored here, like geographic origin
Select
	IDKey as IDKey ,
	cast(AnimalID as varchar) as Id,
	p.PoolCode as PoolCode,    ----- Ref_Pool
	rp.ShortDescription AS category,
	rp.Description,
	DateAssigned as DateAssigned  ,
	DateReleased as DateReleased ,
	Status as  Status,            ---- flag = 1 Active pools, Flag = 0 Inactive Pools

	p.objectid,
	p.ts as rowversion

From Af_Pool p
left join ref_pool rp ON (rp.PoolCode = p.PoolCode)
