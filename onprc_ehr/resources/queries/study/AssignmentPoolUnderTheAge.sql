-- /* Added by Kollil, June 2026
--    Refer to tkt # 14056
--    Instead of a general > note, they now have a flag - Category: Assign Alias, Meaning: Assignment pool.
--      I think we could keep the grid the same, except replace the field "notes pertaining to DAR" with
--      the "Meaning" field from the active flags page. Although could we rename the column so it's called "Flag"?
--    */

SELECT
    a.Id,
    a.Id.demographics.gender AS Sex,
    a.Id.Age.ageinyears AS Age,
    a.Id.curlocation.room AS Room,
    a.Id.curlocation.cage AS Cage,
    'Assignment Pool' AS Flag,

    (
        SELECT GROUP_CONCAT(DISTINCT CAST(h.roommateId AS VARCHAR), ', ')
        FROM housingRoommatesDivider h
        WHERE h.Id = a.Id
          AND h.removalDate IS NULL
          AND h.roommateEnd IS NULL
          AND h.roommateId IS NOT NULL
    ) AS Cagemates,

    (
        SELECT GROUP_CONCAT(DISTINCT CAST(d.project.displayname AS VARCHAR), ', ')
        FROM housingRoommatesDivider h
                 LEFT JOIN study.assignment d
                           ON d.Id = h.roommateId
        WHERE h.Id = a.Id
          AND h.removalDate IS NULL
          AND h.roommateEnd IS NULL
          AND h.roommateId IS NOT NULL
          --AND d.enddate IS NULL
          --AND d.isActive = 1
          --AND d.project.displayname NOT IN ('0492-02', '0492-03')
    ) AS Cagemate_Assignments

FROM study.Assignment a
WHERE
    --a.enddate IS NULL
    --AND a.isActive = 1
    a.Id.Age.ageinyears <= 3
    --AND a.project.displayname NOT IN ('0492-02', '0492-03')
    AND a.Id.demographics.species = 'Rhesus Macaque'
    AND EXISTS (
        SELECT 1
        FROM study.flags f
        WHERE f.Id = a.Id
          AND f.flag.category = 'Assign Alias'
          AND f.flag.value = 'Assignment Pool'
          AND f.enddate IS NULL
)

