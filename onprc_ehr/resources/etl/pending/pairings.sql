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
/*
Psych_Pairings

Created by: Lakshmi Kolli	Date: 8/16/2012


Tested by:
	Raymond Blasa     Date: 8/21/2012


*/

 SELECT
	--PairingId as PairingId ,
	Animalid1 as Id1 ,
	Animalid2 as Id2 ,
	Pairingdate as date,
	--CageId1 as CageId1 ,
	L1.Location as room1,
	rtrim(r1.row) + convert(char(2), r1.Cage) As Cage1,
	--CageId2 as CageId2 ,
	L2.Location as room2,
	rtrim(r2.row) + convert(char(2), r2.Cage) As Cage2,
	PairingType as PairingTypeInt ,
	s2.Value AS PairingType,
	PairingOutcome as PairingOutcomeInt  ,
	s3.Value as PairingOutcome,
	SeparationReason as SeparationReasonInt ,
	s4.Value AS SeparationReason,
	SeparationDate as SeparationDate ,
	Aggressor as Aggressor ,
	Remarks as Remarks ,
	PairingOrigin as PairingOriginInt ,
	s5.Value AS PairingOrigin,

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

--where pp.ts > ?
