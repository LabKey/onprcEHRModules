--TODO: this needs works
SELECT
p.grantNumber as "grant",
max(p.grantTitle) as title,
count(*) as total

FROM Ref_ProjectGrants p
WHERE p.datedisabled is null
group by p.grantNumber--, p.grantTitle

having MAX(p.ts) > ?