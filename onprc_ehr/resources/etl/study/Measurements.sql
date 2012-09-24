SELECT
	pm.MeasurementID,
	cast(pm.Id as varchar) as Id,
	pm.date,
	pm.TechnicianInt,
	pm.objectid as parentid,
	(cast(pm.objectid as varchar(38)) + pm.tissue) as objectid,
	pm.rowversion,
	pm.tissue,
	pm.measurement,

	LastName as TechLastName,
	FirstName as TechFirstName,
	Initials as TechInitials,
        s1.Value as Department
	
FROM (	

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate as date,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'CrownRump' as tissue,
	CrownRump AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'Transtemporal' as tissue,
	Transtemporal AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'RightHand' as tissue,
	RightHand AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'RightFoot' as tissue,
	RightFoot AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'PrimaryPlacentalDisc1' as tissue,
	PrimaryPlacentalDisc1 AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'PrimaryPlacentalDisc2' as tissue,
	PrimaryPlacentalDisc2 AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'PrimaryPlacentalDisc3' as tissue,
	PrimaryPlacentalDisc3 AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'SecondaryPlacentalDisc1' as tissue,
	SecondaryPlacentalDisc1 AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'SecondaryPlacentalDisc2' as tissue,
	SecondaryPlacentalDisc2 AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'SecondaryPlacentalDisc3' as tissue,
	SecondaryPlacentalDisc3 AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'AbdominalCircumference' as tissue,
	AbdominalCircumference AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'HeadCircumference' as tissue,
	HeadCircumference AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'ThoracicCircumference' as tissue,
	ThoracicCircumference AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'FemurLength' as tissue,
	FemurLength AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'TorsoLength' as tissue,
	TorsoLength AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'HeartLAV' as tissue,
	HeartLAV AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'HeartRAV' as tissue,
	HeartRAV AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'HeartPUL' as tissue,
	HeartPUL AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'HeartAO' as tissue,
	HeartAO AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'HeartLVW' as tissue,
	HeartLVW AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'HeartRVW' as tissue,
	HeartRVW AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'HeartIVS' as tissue,
	HeartIVS AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	TissueSnomed1 as tissue,
	Tissue1Dimension1 AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	TissueSnomed1 as tissue,
	Tissue1Dimension2 AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	TissueSnomed1 as tissue,
	Tissue1Dimension3 AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	TissueSnomed2 as tissue,
	Tissue2Dimension1 AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	TissueSnomed2 as tissue,
	Tissue2Dimension2 AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	TissueSnomed3 as tissue,
	Tissue3Dimension3 AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	TissueSnomed4 as tissue,
	Tissue4Dimension1 AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	TissueSnomed4 as tissue,
	Tissue4Dimension2 AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	TissueSnomed4 as tissue,
	Tissue4Dimension3 AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	TissueSnomed5 as tissue,
	Tissue5Dimension1 AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	TissueSnomed5 as tissue,
	Tissue5Dimension2 AS measurement

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	TissueSnomed5 as tissue,
	Tissue5Dimension3 AS measurement

From Path_Measurements pm

) pm

left join Ref_Technicians rt on pm.TechnicianInt = rt.ID
left join Sys_Parameters s1 on (s1.Flag = rt.DeptCode And s1.Field = 'DepartmentCode')

where measurement > 0
and pm.rowversion > ?