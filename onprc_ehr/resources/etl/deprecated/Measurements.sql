/*
 * Copyright (c) 2012-2014 LabKey Corporation
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
  (cast(pm.objectid as varchar(38)) + '||' + coalesce(pm.tissue, '') + '||' + CAST(pm.measurement1 as nvarchar(4000))) as objectid,
	--pm.rowversion,

	--pm.MeasurementID,
	pm.tissue,
	pm.measurement1,
    pm.measurement2,
    pm.measurement3,
    null as category,
    'cm' as units,

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
  'T-Y9650' as tissue,
	--'Crown Rump' as dimension,
	CrownRump AS measurement1,
  null AS measurement2,
  null AS measurement3

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
  'T-Y9750' as tissue,
	--'Transtemporal' as dimension,
	Transtemporal AS measurement1,
  null AS measurement2,
  null AS measurement3

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'T-Y8710' as tissue, --right hand
  --null as dimension,
	RightHand AS measurement1,
  null AS measurement2,
  null AS measurement3

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'T-Y9710' as tissue,  --right foot
  --null as dimension,
	RightFoot AS measurement1,
  null AS measurement2,
  null AS measurement3

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'T-YZ050' as tissue,
  --null as dimension,
	PrimaryPlacentalDisc1 AS measurement1,
  PrimaryPlacentalDisc2 AS measurement2,
  PrimaryPlacentalDisc3 AS measurement3

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'T-YZ060' as tissue,
  --null as dimension,
	SecondaryPlacentalDisc1 AS measurement1,
  SecondaryPlacentalDisc2 AS measurement2,
  SecondaryPlacentalDisc3 AS measurement3

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
  'T-Y9855' as tissue,
	--'Abdominal Circumference' as dimension,
	AbdominalCircumference AS measurement1,
  null AS measurement2,
  null AS measurement3

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
  'T-Y9845' as tissue,
	--'Head Circumference' as dimension,
	HeadCircumference AS measurement1,
  null AS measurement2,
  null AS measurement3

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
  'T-Y9889' as tissue,
	--'Thoracic Circumference' as dimension,
	ThoracicCircumference AS measurement1,
  null AS measurement2,
  null AS measurement3

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
  'T-Y9880' as tissue,
	--'Femur Length' as dimension,
	FemurLength AS measurement1,
  null AS measurement2,
  null AS measurement3

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
  'T-Y9865' as tissue,
	--'Torso Length' as dimension,
	TorsoLength AS measurement1,
  null AS measurement2,
  null AS measurement3

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'T-36000' as tissue,  --heart
  --'LAV' as dimension,
	HeartLAV AS measurement1,
  null AS measurement2,
  null AS measurement3

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'T-38000' as tissue,  --heart
  --'RAV' as dimension,
	HeartRAV AS measurement1,
  null AS measurement2,
  null AS measurement3

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'T-37000' as tissue,  --heart
  --'PUL' as dimension,
	HeartPUL AS measurement1,
  null AS measurement2,
  null AS measurement3

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'T-39000' as tissue,   --heart
  --'AO' as dimension,
	HeartAO AS measurement1,
  null AS measurement2,
  null AS measurement3

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
	'T-Y9890' as tissue,   --heart
  --'LVW' as dimension,
	HeartLVW AS measurement1,
  null AS measurement2,
  null AS measurement3

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
  'T-Y9870' as tissue,  --heart
  --'RVW' as dimension,
	HeartRVW AS measurement1,
  null AS measurement2,
  null AS measurement3

From Path_Measurements pm

UNION ALL

Select
	MeasurementID,
	AnimalID as Id,
	MeasurementDate,
	Technician As TechnicianInt,
	pm.objectid,
	pm.ts as rowversion,
  'T-32410' as tissue,  --heart
	--'IVS' as dimension,
	HeartIVS AS measurement1,
  null AS measurement2,
  null AS measurement3

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
  --null as dimension,
	Tissue1Dimension1 AS measurement1,
	Tissue1Dimension2 AS measurement2,
	Tissue1Dimension3 AS measurement3

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
  --null as dimension,
	Tissue2Dimension1 AS measurement1,
	Tissue2Dimension2 AS measurement2,
	Tissue3Dimension3 AS measurement3

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
  --null as dimension,
	Tissue4Dimension1 AS measurement1,
	Tissue4Dimension2 AS measurement2,
	Tissue4Dimension3 AS measurement3

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
  --null as dimension,
	Tissue5Dimension1 AS measurement1,
	Tissue5Dimension2 AS measurement2,
	Tissue5Dimension3 AS measurement3

From Path_Measurements pm

) pm

left join Ref_Technicians rt on pm.TechnicianInt = rt.ID
left join Sys_Parameters s1 on (s1.Flag = rt.DeptCode And s1.Field = 'DepartmentCode')

where (measurement1 > 0 or measurement2 > 0 or measurement3 > 0)
and pm.rowversion > ?

UNION ALL

SELECT
	cast(t.AnimalID as nvarchar(4000)) as Id,
	t.date,
  t.objectid as parentId,
	(cast(t.objectid as varchar(38)) + t.tissue + CAST(t.measurement1 as nvarchar(4000))) as objectid,
	t.tissue,
  t.measurement1,
  t.measurement2,
  null as measurement3,
  'Placental' as category,
  'cm' as units,

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
  'T-Y9650' as tissue,
	--'Crown Rump' as dimension,
	CrownRump as measurement1,
  null as measurement2,

	Technician,
	path.objectid,
	path.ts

From Path_FetalMeasurements Path
where CrownRump > 0

UNION ALL

Select

	AnimalID,
	MeasurementDate as date,
  'T-Y9750' as tissue,
	--'Transtemporal' as dimension,
	Transtemporal as measurement1,
  null as measurement2,

	Technician,
	path.objectid,
	path.ts

From Path_FetalMeasurements Path
where Transtemporal > 0

UNION ALL

Select

	AnimalID,
	MeasurementDate as date,
	'T-Y8710' as tissue,  --right hand
  --null as dimension,
	RightHand as measurement1,
  null as measurement2,

	Technician,
	path.objectid,
	path.ts

From Path_FetalMeasurements Path
where RightHand > 0

UNION ALL

Select

	AnimalID,
	MeasurementDate as date,
	'T-Y9710' as tissue,   --right foot
  --null as dimension,
	RightFoot as measurement1,
  null as measurement2,

	Technician,
	path.objectid,
	path.ts

From Path_FetalMeasurements Path
where RightFoot > 0

UNION ALL

Select

	AnimalID,
	MeasurementDate as date,
	'T-YZ050' as tissue,
  --null as dimension,
	PrimaryPlacentalDisc1 as measurement1,
	PrimaryPlacentalDisc2 as measurement2,

	Technician,
	path.objectid,
	path.ts

From Path_FetalMeasurements Path
where (PrimaryPlacentalDisc1 > 0 or PrimaryPlacentalDisc2 > 0)

UNION ALL

Select

	AnimalID,
	MeasurementDate as date,
	'T-YZ060' as tissue,
  --null as dimension,
	SecondaryPlacentalDisc1 as measurement1,
	SecondaryPlacentalDisc2 as measurement2,

	Technician,
	path.objectid,
	path.ts

From Path_FetalMeasurements Path
where (SecondaryPlacentalDisc1 > 0 OR SecondaryPlacentalDisc2 > 0)

) t

left join Ref_Technicians rt on (t.Technician = rt.ID)
left join Sys_Parameters s1 on (s1.Flag = rt.DeptCode And s1.Field = 'DepartmentCode')

where t.ts > ?