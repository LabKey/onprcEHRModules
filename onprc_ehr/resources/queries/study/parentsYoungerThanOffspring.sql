SELECT
    p.Id,
    p.parent,
    p.relationship,
    p.method,
    p.Id.demographics.birth,
    p.parent.demographics.birth as parentBirth,
    p.lsid,
    'Parentage' as queryName

FROM study.parentage p
WHERE
    p.qcstate.publicdata = true AND
    (p.Id.demographics.birth IS NOT NULL AND p.parent.demographics.birth IS NOT NULL AND p.Id.demographics.birth <= p.parent.demographics.birth)

UNION ALL

SELECT
    p.Id,
    p.dam as parent,
    'Dam' as relationship,
    'Observed' as method,
    p.Id.demographics.birth,
    d.birth as parentBirth,
    p.lsid,
    'Birth' as queryName

FROM study.birth p
JOIN study.demographics d on (p.dam = d.Id)
WHERE
    p.qcstate.publicdata = true AND
    (p.Id.demographics.birth IS NOT NULL AND d.birth IS NOT NULL AND p.Id.demographics.birth <= d.birth)

UNION ALL

SELECT
    p.Id,
    p.sire as parent,
    'Sire' as relationship,
    'Observed' as method,
    p.Id.demographics.birth,
    d.birth as parentBirth,
    p.lsid,
    'Birth' as queryName

FROM study.birth p
JOIN study.demographics d on (p.sire = d.Id)
WHERE
    p.qcstate.publicdata = true AND
    (p.Id.demographics.birth IS NOT NULL AND d.birth IS NOT NULL AND p.Id.demographics.birth <= d.birth)
