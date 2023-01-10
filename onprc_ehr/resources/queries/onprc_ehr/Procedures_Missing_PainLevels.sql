-- This query extracts the procedures that were used currently with missing USDA pain categories.
Select
    e.id,
    e.project,
    e.date,
    p.name,
    p.PainCategories
From study.encounters e, ehr_lookups.procedures p
Where e.procedureid = p.rowid
And p.PainCategories IS NULL