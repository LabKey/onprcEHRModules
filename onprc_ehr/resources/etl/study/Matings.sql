SELECT
	cast(AnimalID as varchar) as Id,
	Date as Date  ,
	MaleId as Male,
	--MatingType as MatingTypeInt  ,
	s1.Value as MatingType,
	--Technician As PerformedByInt,
	--LastName as TechLastName,
	--FirstName as TechFirstName,
	--Initials as TechInitials,
	--DeptCode as DepartmentCodeInt,
	--s2.Value as DepartmentCode,
	--IDKey as IDKey,
	bm.ts as rowversion,
	bm.objectid AS objectid

FROM Brd_Matings bm
left join Sys_parameters s1 ON (s1.Field = 'MatingType' and s1.Flag = MatingType)
left join Ref_Technicians rt ON (bm.Technician = rt.ID)
left join Sys_parameters s2 On (s2.Field = 'DepartmentCode' and s2.Flag = rt.DeptCode)

where bm.ts > ?