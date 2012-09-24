Select
	cast(afd.AnimalID as varchar) as Id,
	afd.Date as Date,
	afd.ISISDestination as desintationId,
	isis.InstitutionName as desintation,	
	
	afd.Technician as TechnicianInt ,						----- Ref_Technicians
	rt.LastName as TechLastName,
	rt.FirstName as TechFirstName,
	rt.Initials as TechInitials,
	rt.DeptCode as DepartmentInt,
	s1.Value as Department,
	afd.IDKey as IDKey,
	
	afd.Remarks as Remark,
	afd.objectid,
	afd.ts as rowversion

From AF_Departure afd
LEFT JOIN Ref_Technicians rt ON (afd.Technician = rt.ID)
LEFT JOIN Sys_Parameters s1 ON (s1.Field = 'DepartmentCode' and s1.Flag = rt.DeptCode)
left join Ref_ISISInstitution isis ON (isis.InstitutionCode = ISISDestination)

where afd.ts > ?