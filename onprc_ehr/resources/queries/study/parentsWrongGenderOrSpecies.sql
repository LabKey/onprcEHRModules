SELECT
    p.Id,
    p.Id.demographics.species,
    p.relationship,
    p.parent,
    p.parent.demographics.gender as parentGender,
    p.parent.demographics.species as parentSpecies,
    p.lsid
FROM study.parentage p

WHERE p.qcstate.publicdata = true AND (
     -- Gender:
    (p.parent.demographics.gender.origgender IS NOT NULL AND p.relationship = 'Sire' AND p.parent.demographics.gender.origgender != 'm') OR
    (p.parent.demographics.gender.origgender IS NOT NULL AND p.relationship = 'Dam' AND p.parent.demographics.gender.origgender != 'f') OR

    -- Species
    (p.Id.demographics.species IS NOT NULL AND p.parent.demographics.species IS NOT NULL AND p.Id.demographics.species != p.parent.demographics.species)
)