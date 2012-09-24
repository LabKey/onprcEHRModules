SELECT
	cast(AnimalId as varchar) as Id,
	Date,
	Medication as code,
	sno.Description as snomedMeaning,
	Dose as Dose,
	--Units as UnitsInt ,
	s2.Value as Units,
	--Route as RouteInt ,
	s3.Value as Route,
	--Frequency as FrequencyInt ,
	--TODO: convert this
	--s4.Value as Frequency,
	Duration as Duration,
	EndDate as EndDate,
	--Reason as ReasonInt  ,
	s5.Value as Reason,
	--RenewalFlag as RenewalFlag ,
	--Technician As TechnicianID,
	--LastName as TechLastName,
	--FirstName as TechFirstName,
	--Initials as TechInitials,
	--DeptCode as DepartmentCodeInt,
	--s6.Value as DepartmentCode,
	Remarks as Remark,
	--cln.SearchKey as SearchKey,

	cln.ts as rowversion,
	cln.objectid

FROM Cln_Medications cln
     left join  Ref_Technicians rt on (cln.Technician = rt.ID)
     left join Sys_parameters s2 on (s2.Field = 'MedicationUnits'and s2.Flag = Units)
     left join Sys_parameters s3 on (s3.Field = 'MedicationRoute'and s3.Flag = Route)
     left join Sys_parameters s4 on (s4.Field = 'MedicationFrequency' and s4.Flag = Frequency)
     left join Sys_parameters s5 on (s5.Field = 'MedicationReason' and s5.Flag = Reason)
     left join Sys_parameters s6 on (s6.Field = 'DepartmentCode' and s6.Flag = rt.DeptCode)
     left join ref_snomed121311 sno on (sno.SnomedCode = cln.Medication)

where cln.ts > ?