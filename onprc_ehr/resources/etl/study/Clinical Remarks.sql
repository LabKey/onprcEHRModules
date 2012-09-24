Select
	cast(afc.AnimalID as varchar) as Id,
	date,

	labkey.core.GROUP_CONCAT_D(Afc.objectid, ';') as objectid,
	max(Afc.ts) as rowversion,
	afc.DiagnosisID,

	labkey.core.GROUP_CONCAT_D(Remarks, ', ') as remark
FROM (
SELECT
  --note: this is necessary for SQLServer to allow ORDER BY in the subquery
  top 99999999999999999
  dx.AnimalID,
  dx.Date,
  cr.objectid,
  cr.ts,
  dx.DiagnosisID,
  cr.Remarks

FROM Cln_DxRemarks cr
LEFT JOIN Cln_DX dx ON (cr.DiagnosisID = dx.DiagnosisID)

--TODO: account for all rowversions
--WHERE cr.ts > ?

ORDER BY dx.DiagnosisID, cr.SequenceNo

) afc

GROUP BY afc.AnimalID, afc.Date, afc.DiagnosisID

having max(afc.ts) > ?