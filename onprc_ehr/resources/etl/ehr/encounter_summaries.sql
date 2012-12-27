Select
    cast(pat.AnimalID as nvarchar(4000)) as Id,
	pat.Date,
	l.LogText as remark,
	--l.SequenceNo,

	pat.objectid as parentid,
	l.objectid
From Path_Autopsy Pat
left join Path_AutopsyLog l ON (l.AutopsyID = pat.AutopsyId)
where l.LogText is not null and DATALENGTH(l.LogText) > 0 and l.LogText != '' and l.LogText not like 'Testing testing%'
and pat.ts > ?

UNION ALL

Select
    cast(pat.AnimalID as nvarchar(4000)) as Id,
	pat.Date,
	l.LogText as remark,
	--l.SequenceNo,

	pat.objectid as parentid,
	l.objectid
From Path_Biopsy Pat
left join Path_BiopsyLog l ON (l.BiopsyID = pat.BiopsyId)
where l.LogText is not null and DATALENGTH(l.LogText) > 0 and l.LogText != '' and l.LogText not like 'Testing testing%'
and pat.ts > ?

UNION ALL

select * FROM (
Select
    cast(pat.AnimalID as nvarchar(4000)) as Id,
	pat.Date,
	REPLACE(
	cast(coalesce(log0.logtext, '') as nvarchar(4000)) +
	cast(coalesce(log1.logtext, '') as nvarchar(4000)) +
	cast(coalesce(log2.logtext, '') as nvarchar(4000)) +
	cast(coalesce(log3.logtext, '') as nvarchar(4000)) +
	cast(coalesce(log4.logtext, '') as nvarchar(4000)) +
	cast(coalesce(log5.logtext, '') as nvarchar(4000)) +
	cast(coalesce(log6.logtext, '') as nvarchar(4000)) +
	cast(coalesce(log7.logtext, '') as nvarchar(4000)) +
	cast(coalesce(log8.logtext, '') as nvarchar(4000))
	--TODO
	, char(25), CHAR(10)) AS remark,

	pat.objectid as parentid,
	log0.objectid
From Sur_General Pat
left join Sur_Log log0 ON (log0.SurgeryID = pat.SurgeryID and log0.SequenceNo = 0)
left join Sur_Log log1 ON (log1.SurgeryID = pat.SurgeryID and log1.SequenceNo = 1)
left join Sur_Log log2 ON (log2.SurgeryID = pat.SurgeryID and log2.SequenceNo = 2)
left join Sur_Log log3 ON (log3.SurgeryID = pat.SurgeryID and log3.SequenceNo = 3)
left join Sur_Log log4 ON (log4.SurgeryID = pat.SurgeryID and log4.SequenceNo = 4)
left join Sur_Log log5 ON (log5.SurgeryID = pat.SurgeryID and log5.SequenceNo = 5)
left join Sur_Log log6 ON (log6.SurgeryID = pat.SurgeryID and log6.SequenceNo = 6)
left join Sur_Log log7 ON (log7.SurgeryID = pat.SurgeryID and log7.SequenceNo = 7)
left join Sur_Log log8 ON (log8.SurgeryID = pat.SurgeryID and log8.SequenceNo = 8)

WHERE pat.surgeryid IN (select sl.SurgeryID FROM Sur_Log sl WHERE sl.ts > ?)
) t

WHERE t.remark not like '%Testing testing%' and datalength(t.remark) > 0