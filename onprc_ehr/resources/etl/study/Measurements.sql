/*
 * Copyright (c) 2012-2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
SELECT
	cast(pm.Id as nvarchar(4000)) as Id,
	pm.date,

	pm.objectid as parentid,
	(cast(pm.objectid as varchar(38)) + pm.tissue + CAST(pm.measurement as nvarchar(4000))) as objectid,
	--pm.rowversion,

	--pm.MeasurementID,
	pm.tissue,
	pm.measurement,

	case
	  WHEN rt.LastName = 'Unassigned' or rt.FirstName = 'Unassigned' THEN
        'Unassigned'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ', ' + rt.FirstName + ' (' + rt.Initials + ')'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 THEN
        rt.LastName + ', ' + rt.FirstName
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ' (' + rt.Initials + ')'
      WHEN datalength(rt.Initials) = 0 OR rt.initials = ' ' OR rt.lastname = ' none' THEN
        null
	  else
	   rt.Initials
    END as performedBy
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

UNION ALL

SELECT
	cast(t.AnimalID as nvarchar(4000)) as Id,
	t.date,
	null as parentId,
	(cast(t.objectid as varchar(38)) + t.tissue + CAST(t.measurement as nvarchar(4000))) as objectid,
	t.tissue,
	t.measurement,

	case
	  WHEN rt.LastName = 'Unassigned' or rt.FirstName = 'Unassigned' THEN
        'Unassigned'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ', ' + rt.FirstName + ' (' + rt.Initials + ')'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 THEN
        rt.LastName + ', ' + rt.FirstName
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ' (' + rt.Initials + ')'
      WHEN datalength(rt.Initials) = 0 OR rt.initials = ' ' OR rt.lastname = ' none' THEN
        null
	  else
	   rt.Initials
    END as performedBy

FROM (

Select

	AnimalID,
	MeasurementDate as date,
	'CrownRump' as tissue,
	CrownRump as measurement,

	Technician,
	path.objectid,
	path.ts

From Path_FetalMeasurements Path
where CrownRump > 0

UNION ALL

Select

	AnimalID,
	MeasurementDate as date,
	'Transtemporal' as tissue,
	Transtemporal as measurement,

	Technician,
	path.objectid,
	path.ts

From Path_FetalMeasurements Path
where Transtemporal > 0

UNION ALL

Select

	AnimalID,
	MeasurementDate as date,
	'RightHand' as tissue,
	RightHand as measurement,

	Technician,
	path.objectid,
	path.ts

From Path_FetalMeasurements Path
where RightHand > 0

UNION ALL

Select

	AnimalID,
	MeasurementDate as date,
	'RightFoot' as tissue,
	RightFoot as measurement,

	Technician,
	path.objectid,
	path.ts

From Path_FetalMeasurements Path
where RightFoot > 0

UNION ALL

Select

	AnimalID,
	MeasurementDate as date,
	'PrimaryPlacentalDisc1' as tissue,
	PrimaryPlacentalDisc1 as measurement,

	Technician,
	path.objectid,
	path.ts

From Path_FetalMeasurements Path
where PrimaryPlacentalDisc1 > 0

UNION ALL

Select

	AnimalID,
	MeasurementDate as date,
	'PrimaryPlacentalDisc2' as tissue,
	PrimaryPlacentalDisc2 as measurement,

	Technician,
	path.objectid,
	path.ts

From Path_FetalMeasurements Path
where PrimaryPlacentalDisc2 > 0

UNION ALL

Select

	AnimalID,
	MeasurementDate as date,
	'SecondaryPlacentalDisc1' as tissue,
	SecondaryPlacentalDisc1 as measurement,

	Technician,
	path.objectid,
	path.ts

From Path_FetalMeasurements Path
where SecondaryPlacentalDisc1 > 0

UNION ALL

Select

	AnimalID,
	MeasurementDate as date,
	'SecondaryPlacentalDisc2' as tissue,
	SecondaryPlacentalDisc2 as measurement,

	Technician,
	path.objectid,
	path.ts

From Path_FetalMeasurements Path
where SecondaryPlacentalDisc2 > 0

) t

left join Ref_Technicians rt on (t.Technician = rt.ID)
left join Sys_Parameters s1 on (s1.Flag = rt.DeptCode And s1.Field = 'DepartmentCode')

where t.ts > ?