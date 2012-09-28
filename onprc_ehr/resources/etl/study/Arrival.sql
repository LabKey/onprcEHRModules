/*
 * Copyright (c) 2012 LabKey Corporation
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
Select
	cast(AnimalID as varchar) as Id,
	Date as Date,	
    s1.Value as AcquisitionType,
    s2.Value as RearingType,
    Afc.ISISInstitute as source,
    Remarks as Remark,
    Refis.GeographicName as geoOrigin,

    CASE
      WHEN (RefLoc.Location = 'No Location') then null
      else RefLoc.Location
    END as initialRoom,
	rtrim(Refrow.row) + '-' + convert(char(2), RefRow.Cage) As initialCage,

    --TODO
    s3.Value as AcquisitionAge,
    RefTT.InstitutionName as ISISInstitute,
	NonISISSource as NonISISSource ,

	--Afc.AcquisitionType as AcquisitionInt ,
	--Afc.RearingType as RearingTypeInt ,
	--Afc.AcquisitionAge as AcquisitionAgeInt,
	--Afc.GeographicOrigin as GeographicOriginInt  ,
	--OLDIdNumber as OLDIdNumber,
	--InitialLocID as InitialLocIDInt ,
	--Technician as TechnicianInt,
	--Ref.LastName as TechLastName,
	--Ref.FirstName as TechFirstName,
	--Ref.Initials as TechInitials,
	--DeptCode as DepartmentInt,
	--s4.Value as Department,

	--IDKey as IDKey,
	Afc.objectid
	--Afc.ts as rowversion

From Af_Acquisition Afc
LEFT JOIN Sys_parameters s1 ON (s1.Field = 'AcquistionType' AND s1.Flag = Afc.AcquisitionType)
LEFT JOIN Sys_parameters s2 ON (s2.Flag = afc.RearingType and s2.Field = 'RearingType') 
LEFT JOIN Sys_parameters s3 ON (s3.Flag = afc.AcquisitionAge and s3.Field = 'AcquisitionAge') 
LEFT JOIN Ref_Technicians Ref ON (Ref.ID = Afc.Technician) 
LEFT JOIN Sys_parameters s4 ON (s4.Field = 'DepartmentCode' and s4.Flag = Ref.DeptCode) 
LEFT JOIN Ref_RowCage RefRow ON (RefRow.CageID = Afc.InitialLocID) 
LEFT JOIN Ref_Location RefLoc ON (RefRow.LocationID = RefLoc.LocationID) 
LEFT JOIN Ref_IsisGeographic RefIs ON (Afc.GeographicOrigin = RefIs.GeographicCode)
LEFT JOIN Ref_IsisInstitution RefTT ON (afc.ISISInstitute = RefTT.Institutioncode)

WHERE afc.ts > ?