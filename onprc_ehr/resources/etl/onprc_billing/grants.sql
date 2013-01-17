--TODO: this needs works
SELECT
p.grantNumber as "grant",
max(p.grantTitle) as title,
MAX(CONVERT(varchar(38), p.objectid)) as objectid,
count(*) as total

FROM Ref_ProjectGrants p
WHERE p.datedisabled is null
group by p.grantNumber--, p.grantTitle

having MAX(p.ts) > ?