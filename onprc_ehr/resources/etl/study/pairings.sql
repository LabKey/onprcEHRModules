/*
Psych_Pairings

Created by: Lakshmi Kolli	Date: 8/16/2012


Tested by:
	Raymond Blasa     Date: 8/21/2012


*/

 SELECT
	--PairingId as PairingId ,
	cast(pp.Animalid1 as nvarchar(4000)) as Id
	cast(pp.Animalid2 as nvarchar(4000)) as Id2,
	pp.Pairingdate as date,
	pp.SeparationDate as enddate,
	--CageId1 as CageId1 ,
	L1.Location as room1,
	rtrim(r1.row) + convert(char(2), r1.Cage) As Cage1,
	--CageId2 as CageId2 ,
	L2.Location as room2,
	rtrim(r2.row) + convert(char(2), r2.Cage) As Cage2,
	pp.PairingType as PairingType,
	--s2.Value AS PairingType,
	pp.PairingOutcome as PairingOutcome,
	--s3.Value as PairingOutcome,
	pp.SeparationReason as SeparationReason,
	--s4.Value AS SeparationReason,
		
	pp.Aggressor as Aggressor ,
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
