/*
Cln_DX

Case Type: This is not a Sys_Parameter. But, the Case types are defined in the VB code.

Global Const CLINICALCASE	= 1
Global Const SURGERYCASE	= 2
Global Const BEHAVIORCASE	= 3
Global Const WeightsCase	= 4

Created by: Lakshmi Kolli	Date: 8/9/2012


Tested by: 			Date:
         Raymond Blasa             8/22/2012

*/

SELECT
	--DiagnosisID  as DiagnosisID ,
	cln.AnimalID as Id ,
	cln.Date ,
	--cln.CaseID,       ---- Af_Case
	c.objectid as caseId,
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
	CASE
		WHEN CaseType = 1 THEN 'Clinical'
		WHEN CaseType = 2 THEN 'Surgery'
		WHEN CaseType = 3 THEN 'Behavior'
		WHEN CaseType = 4 THEN 'Weight'
	END as CaseType,

    rm.remark,
    
	cln.objectid

FROM Cln_Dx cln
     left join  Ref_Technicians rt on (cln.Technician = rt.ID)
     left join  Sys_parameters s4 on (s4.Field = 'DepartmentCode' And s4.Flag = rt.DeptCode)
     left join Af_Case c ON (c.CaseID = cln.CaseID)

LEFT JOIN (

SELECT 
	cln0.DiagnosisID ,
	
	REPLACE(	
	cast(coalesce(cln0.Remarks, '') as nvarchar(4000)) + 
	cast(coalesce(cln1.Remarks, '') as nvarchar(4000)) + 
	cast(coalesce(cln2.Remarks, '') as nvarchar(4000)) + 
	cast(coalesce(cln3.Remarks, '') as nvarchar(4000)) + 
	cast(coalesce(cln4.Remarks, '') as nvarchar(4000)) + 
	cast(coalesce(cln5.Remarks, '') as nvarchar(4000))
	, '', '') AS remark,
	
	cln0.objectid,
	
	cln0.ts as ts0,
	cln1.ts as ts1,
	cln2.ts as ts2,
	cln3.ts as ts3,
	cln4.ts as ts4,
    cln5.ts as ts5

FROM Cln_DxRemarks cln0
LEFT JOIN Cln_DxRemarks cln1 ON (cln0.DiagnosisID = cln1.DiagnosisID AND cln1.SequenceNo = 1)
LEFT JOIN Cln_DxRemarks cln2 ON (cln0.DiagnosisID = cln2.DiagnosisID AND cln2.SequenceNo = 2)
LEFT JOIN Cln_DxRemarks cln3 ON (cln0.DiagnosisID = cln3.DiagnosisID AND cln3.SequenceNo = 3)
LEFT JOIN Cln_DxRemarks cln4 ON (cln0.DiagnosisID = cln4.DiagnosisID AND cln4.SequenceNo = 4)
LEFT JOIN Cln_DxRemarks cln5 ON (cln0.DiagnosisID = cln5.DiagnosisID AND cln5.SequenceNo = 5)
where cln0.SequenceNo = 0

) rm ON (rm.DiagnosisID = cln.DiagnosisID)

WHERE (cln.ts > ? OR rm.ts0 > ? OR rm.ts1 > ? OR rm.ts2 > ? OR rm.ts3 > ? OR rm.ts4 > ? OR rm.ts5 > ?)
