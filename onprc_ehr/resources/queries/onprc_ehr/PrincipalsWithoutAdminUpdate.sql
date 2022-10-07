
SELECT
    u.UserId,
    u.DisplayName,
    'u' as Type,
    u.FirstName,
    u.LastName

FROM onprc_ehr.usersActiveNames u


UNION ALL

SELECT
    g.UserId,
    g.Name as DisplayName,
    'g' as Type,
    null as FirstName,
    null as LastName

FROM core.groups g
WHERE g.userid > 0