Select
    e.id,
    e.project,
    e.date,
    e.procedureid,
    p.PainCategories
From study.encounters e, ehr_lookups.procedures p
Where e.procedureid = p.rowid
And p.PainCategories IS NULL