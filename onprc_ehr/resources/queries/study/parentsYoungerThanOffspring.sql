SELECT
    p.Id,
    p.parent,
    p.relationship,
    p.method,
    p.Id.demographics.birth,
    p.parent.demographics.birth as parentBirth,
    p.lsid

FROM study.parentage p
WHERE
    p.qcstate.publicdata = true AND
    (p.Id.demographics.birth IS NOT NULL AND p.parent.demographics.birth IS NOT NULL AND p.Id.demographics.birth <= p.parent.demographics.birth)
