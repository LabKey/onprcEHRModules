-- This query gets the pain categories
-- B, C, D
SELECT rowid, value FROM ehr_lookups.lookups l WHERE l.set_name = 'Procedure_Pain_Categories' order by sort_order