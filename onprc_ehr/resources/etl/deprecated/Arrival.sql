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
Select
	cast(AnimalID as nvarchar(4000)) as Id,
	Date as Date,

	(SELECT rowid FROM labkey.ehr_lookups.lookups l WHERE l.set_name = 'AcquistionType' and l.value = s1.value) as AcquisitionType,
    s1.Value as AcquisitionTypeMeaning,

    (SELECT rowid FROM labkey.ehr_lookups.lookups l WHERE l.set_name = 'RearingType' and l.value = s2.value) as RearingType,
    s2.Value as RearingTypeMeaning,

    Afc.ISISInstitute as source,
    Remarks as Remark,
    Refis.GeographicName as geographic_origin,
    oldIdNumber as originalId,

    --TODO: add these fields??
    s3.Value as AcquisitionAge,
	NonISISSource as NonISISSource ,

    CASE
      WHEN (RefLoc.Location = 'No Location') then null
      else RefLoc.Location
    END as initialRoom,
	rtrim(ltrim(rtrim(Refrow.row) + convert(char(2), RefRow.Cage))) As initialCage,

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
    END as performedBy,

	Afc.objectid
	--Afc.ts as rowversion

From Af_Acquisition Afc
LEFT JOIN Sys_parameters s1 ON (s1.Field = 'AcquistionType' AND s1.Flag = Afc.AcquisitionType)
LEFT JOIN Sys_parameters s2 ON (s2.Flag = afc.RearingType and s2.Field = 'RearingType') 
LEFT JOIN Sys_parameters s3 ON (s3.Flag = afc.AcquisitionAge and s3.Field = 'AcquisitionAge') 
LEFT JOIN Ref_Technicians rt ON (rt.ID = Afc.Technician)
LEFT JOIN Sys_parameters s4 ON (s4.Field = 'DepartmentCode' and s4.Flag = rt.DeptCode)
LEFT JOIN Ref_RowCage RefRow ON (RefRow.CageID = Afc.InitialLocID) 
LEFT JOIN Ref_Location RefLoc ON (RefRow.LocationID = RefLoc.LocationID) 
LEFT JOIN Ref_IsisGeographic RefIs ON (Afc.GeographicOrigin = RefIs.GeographicCode)
LEFT JOIN Ref_IsisInstitution RefTT ON (afc.ISISInstitute = RefTT.Institutioncode)

WHERE afc.ts > ?