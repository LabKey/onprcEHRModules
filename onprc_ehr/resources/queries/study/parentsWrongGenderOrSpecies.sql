SELECT
    p.Id,
    p.date,
    p.Id.demographics.species,
    p.relationship,
    p.parent,
    p.parent.demographics.gender as parentGender,
    p.parent.demographics.species as parentSpecies,
    p.lsid,
    'Parentage' as queryName
FROM study.parentage p

WHERE p.qcstate.publicdata = true AND (
     -- Gender:
    (p.parent.demographics.gender.origgender IS NOT NULL AND p.relationship = 'Sire' AND p.parent.demographics.gender.origgender != 'm') OR
    (p.parent.demographics.gender.origgender IS NOT NULL AND p.relationship = 'Dam' AND p.parent.demographics.gender.origgender != 'f') OR
    (p.parent.demographics.gender.origgender IS NOT NULL AND p.relationship = 'Foster Dam' AND p.parent.demographics.gender.origgender != 'f') OR

    -- Species
    (p.Id.demographics.species IS NOT NULL AND p.parent.demographics.species IS NOT NULL AND p.Id.demographics.species != p.parent.demographics.species)
)

UNION ALL

SELECT
    p.Id,
    p.date,
    p.Id.demographics.species,
    'dam' as relationship,
    p.dam as parent,
    d.gender as parentGender,
    d.species as parentSpecies,
    p.lsid,
    'Birth' as queryName
FROM study.birth p
JOIN study.demographics d on (p.dam = d.Id)
WHERE p.qcstate.publicdata = true AND (
    (d.gender.origgender IS NOT NULL AND d.gender.origgender != 'f') OR
    (p.Id.demographics.species IS NOT NULL AND d.species IS NOT NULL AND p.Id.demographics.species != d.species)
) AND p.date >= '2000-01-01'

UNION ALL

SELECT
    p.Id,
    p.date,
    p.Id.demographics.species,
    'sire' as relationship,
    p.sire as parent,
    d.gender as parentGender,
    d.species as parentSpecies,
    p.lsid,
    'Birth' as queryName
FROM study.birth p
JOIN study.demographics d on (p.sire = d.Id)
WHERE p.qcstate.publicdata = true AND (
    (d.gender.origgender IS NOT NULL AND d.gender.origgender != 'm') OR
    (p.Id.demographics.species IS NOT NULL AND d.species IS NOT NULL AND p.Id.demographics.species != d.species)
) AND p.date >= '2000-01-01'
