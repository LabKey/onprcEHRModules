Select
	category,
	cast(AnimalID as nvarchar(4000)) as Id,
	date,

	tissue,
	quantity as quantityInt,
	s7.Value as quantity,

	analysis as analysisInt,
	s6.Value as method,

	case
	  WHEN rt.LastName = 'Unassigned' or rt.FirstName = 'Unassigned' THEN
        'Unassigned'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ', ' + rt.FirstName + ' (' + rt.Initials + ')'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 THEN
        rt.LastName + ', ' + rt.FirstName
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ' (' + rt.Initials + ')'
	  else
	   rt.Initials
    END as performedBy,

	cp.ts as rowversion,
	cp.objectid as parentid,
	(cast(cp.objectid as varchar(38)) + '_' + cp.tissue + '_' + category) as objectid

FROM (

Select
	'wetMount1' as category,
	AnimalID,
	date,
	Technician,
	cp.ts,
	cp.objectid,

	WetMount1 as tissue,
	WetQuantity1 as quantity,
	Wet1Analysis as analysis

From Cln_Parasitology cp
where WetMount1 is not null and WetMount1 != ''

UNION ALL

Select
	'wetMount2' as category,
	AnimalID,
	date,
	Technician,
	cp.ts,
	cp.objectid,

	WetMount2 as tissue,
	WetQuantity2 as quantity,
	Wet2Analysis as analysis

From Cln_Parasitology cp
where WetMount2 is not null and WetMount2 != ''

UNION ALL

Select
	'wetMount3' as category,
	AnimalID,
	date,
	Technician,
	cp.ts,
	cp.objectid,

	WetMount3 as tissue,
	WetQuantity3 as quantity,
	Wet3Analysis as analysis

From Cln_Parasitology cp
where WetMount3 is not null and WetMount3 != ''

UNION ALL

Select
	'float1' as category,
	AnimalID,
	date,
	Technician,
	cp.ts,
	cp.objectid,

	Floatation1 as tissue,
	FlotQuantity1 as quantity,
	Flot1Analysis as analysis

From Cln_Parasitology cp
where Floatation1 is not null and Floatation1 != ''

UNION ALL

Select
	'float2' as category,
	AnimalID,
	date,
	Technician,
	cp.ts,
	cp.objectid,

	Floatation2 as tissue,
	FlotQuantity2 as quantity,
	Flot2Analysis as analysis

From Cln_Parasitology cp
where Floatation2 is not null and Floatation2 != ''

UNION ALL

Select
	'float3' as category,
	AnimalID,
	date,
	Technician,
	cp.ts,
	cp.objectid,

	Floatation3 as tissue,
	FlotQuantity3 as quantity,
	Flot3Analysis as analysis

From Cln_Parasitology cp
where Floatation3 is not null and Floatation3 != ''

UNION ALL

Select
	'misc1' as category,
	AnimalID,
	date,
	Technician,
	cp.ts,
	cp.objectid,

	Misc1 as tissue,
	MiscQuantity1 as quantity,
	Misc1Analysis as analysis

From Cln_Parasitology cp
where Misc1 is not null and Misc1 != ''

UNION ALL

Select
	'misc2' as category,
	AnimalID,
	date,
	Technician,
	cp.ts,
	cp.objectid,

	Misc2 as tissue,
	MiscQuantity2 as quantity,
	Misc2Analysis as analysis

From Cln_Parasitology cp
where Misc2 is not null and Misc2 != ''

UNION ALL

Select
	'misc3' as category,
	AnimalID,
	date,
	Technician,
	cp.ts,
	cp.objectid,

	Misc3 as tissue,
	MiscQuantity3 as quantity,
	Misc3Analysis as analysis

From Cln_Parasitology cp
where Misc3 is not null and Misc3 != ''

) cp

left join Ref_Technicians rt on (cp.Technician = rt.ID)
left join Sys_Parameters s4 on (s4.Flag = rt.DeptCode And s4.Field = 'DepartmentCode')
left join Sys_Parameters s6 on (s6.Flag = cp.analysis and s6.Field = 'AnalysisParasitology')
left join Sys_Parameters s7 on (s7.Flag = cp.quantity and s7.Field = 'ParasitologyQuantity')

where cp.ts > ?
