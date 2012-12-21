SELECT 
	cast(dx.AnimalID as nvarchar(4000)) as Id,
	dx.date,
	c.objectid as caseid,
	
	REPLACE(	
	cast(coalesce(cln0.Remarks, '') as nvarchar(4000)) + 
	cast(coalesce(cln1.Remarks, '') as nvarchar(4000)) + 
	cast(coalesce(cln2.Remarks, '') as nvarchar(4000)) + 
	cast(coalesce(cln3.Remarks, '') as nvarchar(4000)) + 
	cast(coalesce(cln4.Remarks, '') as nvarchar(4000)) + 
	cast(coalesce(cln5.Remarks, '') as nvarchar(4000)) +
	cast(coalesce(cln6.Remarks, '') as nvarchar(4000))
	, '', '\n') AS remark,
	
	cln0.objectid,
	dx.objectid as parentid	

FROM Cln_Dx dx
left join Af_Case c ON (dx.CaseID = c.CaseID)
LEFT JOIN Cln_DxRemarks cln0 ON (dx.DiagnosisID = cln0.DiagnosisID AND cln0.SequenceNo = 0)
LEFT JOIN Cln_DxRemarks cln1 ON (dx.DiagnosisID = cln1.DiagnosisID AND cln1.SequenceNo = 1)
LEFT JOIN Cln_DxRemarks cln2 ON (dx.DiagnosisID = cln2.DiagnosisID AND cln2.SequenceNo = 2)
LEFT JOIN Cln_DxRemarks cln3 ON (dx.DiagnosisID = cln3.DiagnosisID AND cln3.SequenceNo = 3)
LEFT JOIN Cln_DxRemarks cln4 ON (dx.DiagnosisID = cln4.DiagnosisID AND cln4.SequenceNo = 4)
LEFT JOIN Cln_DxRemarks cln5 ON (dx.DiagnosisID = cln5.DiagnosisID AND cln5.SequenceNo = 5)
LEFT JOIN Cln_DxRemarks cln6 ON (dx.DiagnosisID = cln6.DiagnosisID AND cln6.SequenceNo = 6)

WHERE (dx.ts > ?  OR cln0.ts > ? OR cln1.ts > ? OR cln2.ts > ? OR cln3.ts > ? OR cln4.ts > ? OR cln5.ts > ? OR cln6.ts> ?)