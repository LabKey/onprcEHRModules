
--- Created: 8-23-2018  R.Blasa
-- Converted to left join to allow cases to appear even though the observation is linked to
-- another animal's case or there is no observation.
SELECT
    c.id,
    c.date,
    c.reviewdate,
    c.isactive,
    c.allProblemCategories,
    c.caseHistory,
    c.isOpen,
    c.objectid,
    o.observations
FROM study.cases AS c
LEFT JOIN study.mostrecentobservationsforcase AS o
    ON c.id = o.id
        AND c.objectid = o.caseid
WHERE c.category = 'Behavior'
