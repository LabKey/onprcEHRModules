select
p.ShortDescription as category,
p.Description as name,
p.Date as date,
p.DateDisabled as enddate,
p.objectid

From ref_pool p
where p.ShortDescription IN ('CBG', 'EBG', 'HBG', 'PBG', 'STG', 'SBG')
and p.ts > ?