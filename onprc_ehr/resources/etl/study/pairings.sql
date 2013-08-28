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
/*
Psych_Pairings

Created by: Lakshmi Kolli	Date: 8/16/2012


Tested by:
	Raymond Blasa     Date: 8/21/2012


*/

 SELECT
	--PairingId as PairingId ,
	cast(pp.Animalid1 as nvarchar(4000)) as Id,
	cast(pp.Animalid2 as nvarchar(4000)) as Id2,
	pp.Pairingdate as date,
	pp.SeparationDate as enddate,
	--CageId1 as CageId1 ,
	L1.Location as room1,
	ltrim(rtrim(rtrim(r1.row) + convert(char(2), r1.Cage))) As Cage1,
	--CageId2 as CageId2 ,
	L2.Location as room2,
	ltrim(rtrim(rtrim(r2.row) + convert(char(2), r2.Cage))) As Cage2,

	--(SELECT rowid FROM labkey.ehr_lookups.lookups l WHERE l.set_name = 'PairingType' and l.value = s2.value) as PairingType,
	--pp.PairingType as PairingType,
	s2.Value AS PairingType,
	--(SELECT rowid FROM labkey.ehr_lookups.lookups l WHERE l.set_name = 'PairingOutcome' and l.value = s3.value) as PairingOutcome,
	--pp.PairingOutcome as PairingOutcome,
	s3.Value as PairingOutcome,

  --(SELECT rowid FROM labkey.ehr_lookups.lookups l WHERE l.set_name = 'PairingSeparationReason' and l.value = s4.value) as SeparationReason,
	--pp.SeparationReason as SeparationReason,
	s4.Value AS SeparationReason,
		
	case when pp.aggressor = 0 then null else cast(pp.aggressor as nvarchar(4000)) end as Aggressor ,
	pp.Remarks as Remark,
	pp.PairingOrigin as PairingOrigin,
	--s5.Value AS PairingOrigin,

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
	pp.objectid

FROM Psych_Pairings PP
     left join Ref_Technicians rt on (PP.Technician = rt.ID)
     left join Sys_parameters s1 on (s1.Field = 'DepartmentCode' And s1.Flag = rt.DeptCode)
     left join Sys_parameters s2 on (s2.Field = 'PairingType' And s2.Flag = PP.PairingType)
     left join Sys_parameters s3 on (s3.Field = 'PairingOutcome' And s3.Flag = PP.PairingOutcome)
     left join  Sys_parameters s4 on (s4.Field = 'PairingSeparationReason' And s4.Flag = PP.SeparationReason)
     left join  Sys_parameters s5 on (s5.Field = 'PairingOrigin' And s5.Flag = PP.PairingOrigin)

     left join Ref_RowCage r1 on  (r1.CageID = PP.CageID1)
     left join Ref_Location L1 on (r1.LocationID = L1.LocationId)

     left join Ref_RowCage r2 on  (r2.CageID = PP.CageID2)
     left join Ref_Location L2 on (r2.LocationID = L2.LocationId)

where pp.ts > ?
