Select
	CASE
		WHEN row.row IS NULL THEN rl.Location
		ELSE rl.Location + '-' + rtrim(row.Row) + CONVERT(varchar, row.Cage)
	END as location,
	rl.Location as room,
	rtrim(row.Row) + CONVERT(varchar, row.Cage) as cage,
	--row.CageTypeID,			--Ref_CageTypes
	--row.CageDivider as CageDividerInt,
	CASE
		WHEN row.CageTypeID = 19 THEN ct.CageDescription
		ELSE CONVERT(VARCHAR, ct.CageDescription + ' - ') + CONVERT(VARCHAR, ct.CageSize)
	END as cagetype,
	s2.Value as CageDivider,
	--row.CagePosition,
	row.objectid

From Ref_RowCage row
	left join Sys_Parameters s1 on (s1.field = 'CageSize' and s1.Flag = row.Size)
	left join Sys_Parameters s2 on (s2.field = 'CageDivider' and s2.Flag = row.CageDivider)
	left join Ref_Location rl ON (rl.LocationId = row.LocationID)
	left join Ref_CageTypes ct ON (ct.CageTypeID = row.CageTypeID)

WHERE row.DateDisabled IS NULL
and row.status = 1
AND row.ts > ?