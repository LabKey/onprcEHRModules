SELECT
 	cast(AnimalID as varchar) as Id,
	MaleId as MaleID ,
	ConfirmationDate as ConfirmationDate ,
	EstDeliveryDate as EstDeliveryDate,
	ConfirmationType as ConfirmationTypeInt  ,
	s1.Value as ConfirmationType,
	Technician As TechnicianID,
	LastName as TechLastName,
	FirstName as TechFirstName,
	Initials as TechInitials,
	DeptCode as DepartmentCodeInt,
	s2.Value as DepartmentCode,
	IDKey as IDKey,
	bm.ts as rowversion,
	bm.objectid

FROM Brd_PregnancyConfirm bm
LEFT JOIN Sys_parameters s1 ON (s1.Field = 'PregnancyConfirm' and s1.Flag = ConfirmationType)
LEFT JOIN Ref_Technicians rt ON (bm.Technician = rt.ID)
LEFT JOIN Sys_parameters s2 ON (s2.Field = 'DepartmentCode' and s2.Flag = rt.DeptCode)