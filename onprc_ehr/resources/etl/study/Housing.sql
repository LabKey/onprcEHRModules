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
	TransferDate as Date,
	RemovalDate as  enddate ,
	--Aft.CageID as  TransferCageID ,
	l2.Location as room,
	rtrim(r2.row) + '-' + convert(char(2), r2.Cage) As cage,

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
	  else
	   rt.Initials
    END as performedBy,

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