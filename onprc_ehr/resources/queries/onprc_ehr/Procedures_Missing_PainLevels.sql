-- This query extracts the active procedures with missing USDA pain categories.
-- Set the date range to 1 year back from curr date
Select
    e.id,
    e.project,
    e.date,
    p.name,
    p.PainCategories
From study.encounters e, ehr_lookups.procedures p
Where e.procedureid = p.rowid
And p.active = 'true'
And p.PainCategories IS NULL
And date > timestampadd(SQL_TSI_YEAR,-1,now())