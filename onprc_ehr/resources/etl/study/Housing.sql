Select
	cast(AnimalID as varchar) as Id,
	TransferDate as Date,
	RemovalDate as  enddate ,
	--Aft.CageID as  TransferCageID ,
	l2.Location as room,
	rtrim(r2.row) + '-' + convert(char(2), r2.Cage) As cage,

	--Reason as ReasonInt,
        s1.Value as Reason,
	Technician as TechnicianID,
  	rt.LastName as TechLastName,
        rt.FirstName as TechFirstName,
        rt.Initials as TechInitials,
        rt.DeptCode as DepartmentInt,
        s2.Value as Department,
	--Latest as Latest,               ---- Flag = 1 Current Transfer Record, Flag = 0 Historical Transfer information

	aft.objectid,
	aft.ts as rowversion

From Af_Transfer  Aft
left join  Ref_Technicians Rt on (Aft.Technician = Rt.ID)
left join  Sys_Parameters s2 on (s2.Flag = Rt.Deptcode And S2.Field = 'Departmentcode')
left join  Sys_Parameters s1 on ( AfT.Reason = s1.Flag And s1.Field = 'TransferReason')
left join  Ref_RowCage r2 on  (r2.CageID = aft.CageID)
left join  Ref_Location l2 on (r2.LocationID = l2.LocationId)

WHERE aft.ts > ?