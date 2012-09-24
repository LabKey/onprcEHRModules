SELECT
	cast(AnimalID as varchar) as Id,
	Date as Date,
	'Menses' as category,
	--Technician As TechnicianID,
	--LastName as TechLastName,
	--FirstName as TechFirstName,
	--Initials as TechInitials,
	--DeptCode as DepartmentCodeInt,
	--s1.Value as DepartmentCode,
	--IDKey As IDKey,
    bm.ts as rowversion,
    bm.objectid

FROM Brd_Menstruations bm

LEFT JOIN Ref_Technicians rt ON (bm.Technician = rt.ID)
LEFT JOIN Sys_parameters s1 ON (s1.Field = 'DepartmentCode' and s1.Flag = rt.DeptCode)

where bm.ts > ?