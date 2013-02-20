SELECT
	cast(w.AnimalID as nvarchar(4000)) as Id,
	w.date,
    (cast(w.objectid as varchar(38)) + '_tb') as objectid

FROM af_weights w
where w.tbflag = 1 and w.ts > ?