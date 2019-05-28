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
	cast(aft.AnimalID as nvarchar(4000)) as Id,
	aft.TransferDate as Date,
	coalesce(aft.RemovalDate, q.deathdate, q.departuredate) as enddate,

	--Aft.CageID as  TransferCageID ,
	l2.Location as room,
	rtrim(ltrim(rtrim(r2.row) + convert(char(2), r2.Cage))) As cage,
    (select l.rowid FROM labkey.ehr_lookups.lookups l where l.set_name = s3.Field and l.value = s3.Value) as housingType,
	(select l.rowid FROM labkey.ehr_lookups.lookups l where l.set_name = s4.Field and l.value = s4.Value) as housingCondition,
	--Reason as ReasonInt,
        s1.Value as Reason,

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

	--Latest as Latest,               ---- Flag = 1 Current Transfer Record, Flag = 0 Historical Transfer information

	aft.objectid
	--aft.ts as rowversion

From Af_Transfer  Aft
left join  Ref_Technicians Rt on (Aft.Technician = Rt.ID)
left join  Sys_Parameters s2 on (s2.Flag = Rt.Deptcode And S2.Field = 'Departmentcode')
left join  Sys_Parameters s1 on ( AfT.Reason = s1.Flag And s1.Field = 'TransferReason')
left join  Ref_RowCage r2 on  (r2.CageID = aft.CageID)
left join  Ref_Location l2 on (r2.LocationID = l2.LocationId)
left join  Sys_Parameters s3 on ( l2.LocationType = s3.Flag And s3.Field = 'LocationType')
left join  Sys_Parameters s4 on ( l2.LocationDefinition = s4.Flag And s4.Field = 'LocationDefinition')

left join Af_Qrf q on (q.animalid = aft.animalid)

WHERE (aft.ts > ? OR q.ts > ?) and l2.Location != 'No Location'