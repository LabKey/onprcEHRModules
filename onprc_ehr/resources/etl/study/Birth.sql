SELECT
	cast(AnimalID as varchar) as Id,
	Date as Date,
		s1.Value as BirthType,	
		s2.Value as BirthCondition,
	Birth_Weight As Weight,
	l1.Location as DeliveryLocationRoom,
	r1.row + '-' + convert(char(2), r1.Cage) As DeliveryLocationCage,
	case
	  WHEN MotherID = 0 THEN null
	  ELSE MotherID
    END As Dam,
	case
	  WHEN FatherID = 0 THEN null
	  ELSE FatherID
    END As Sire,
	Remarks As Remark,	
	
	l2.Location as room,
	r2.row + '-' + convert(char(2), r2.Cage) As cage,
	ConceptualAge as ConceptualAge,
	s3.Value as ConceptualAgeDeterm,
	
	  BirthType as BirthTypeInt,
	  BirthCondition As BirthConditionInt,
	ConceptualAgeDeterm as ConceptualAgeDetermInt,
	BirthWtDescription as BirthWtDescriptionInt,
	s4.Value as BirthWtDescription,
	DeliveryLocation As DeliveryLocationInt,
	AssignedLocation As AssignedLocationInt,
--	?? As Conception,							-- what is column 'conception'
	Technician As PerformedByInt,
	LastName as TechLastName,
	FirstName as TechFirstName,
	Initials as TechInitials,
	DeptCode as DepartmentInt,
	s5.Value as Department,


	afb.ts as rowversion,
	afb.objectid

FROM Af_Birth afb 
	
left join Sys_Parameters s1 on ( s1.Field = 'BirthType' and s1.Flag = afb.BirthType) 
left join Sys_Parameters s2 on (s2.Field = 'BirthCondition' and s2.Flag = afb.BirthCondition) 
left join Sys_Parameters s3 on (s3.Field = 'ConceptualAgeDeterm' and s3.Flag = afb.ConceptualAgeDeterm) 
left join Sys_Parameters s4 on (s4.Field = 'BirthWtDescription' and s4.Flag = afb.BirthWtDescription) 
left join Ref_Technicians rt on ( afb.Technician = rt.ID) 
left join Sys_Parameters s5 on (s5.Field = 'DepartmentCode' and s5.Flag = rt.DeptCode )       
left join Ref_RowCage r1 on (r1.CageID = afb.DeliveryLocation)
left Join Ref_Location l1 on (r1.LocationID = l1.LocationId )
left join Ref_RowCage r2 on  (r2.CageID = afb.AssignedLocation)
left join Ref_Location l2 on (r2.LocationID = l2.LocationId)

where afb.ts > ?