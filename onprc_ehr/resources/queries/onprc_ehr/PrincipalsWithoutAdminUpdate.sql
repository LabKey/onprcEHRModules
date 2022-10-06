
SELECT
    u.UserId,
    u.DisplayName,
    'u' as Type,
    u.FirstName,
    u.LastName,
       u.Active

FROM core.Users u
WHERE u.userid > 0
And u.Active = true

UNION ALL

SELECT
    g.UserId,
    g.Name as DisplayName,
    'g' as Type,
    null as FirstName,
    null as LastName,
    null as Active
FROM core.groups g
WHERE g.userid > 0