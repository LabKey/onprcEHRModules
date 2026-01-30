SELECT
    a.Id,
    a.Id.demographics.gender AS Sex,
    a.Id.Age.ageinyears,
    a.Id.curlocation.room AS Room,
    a.Id.curlocation.cage AS Cage,
    /* Display the (active) Notes Pertaining to DAR note text */
    (
        SELECT MAX(n.value)
        FROM study.Notes n
        WHERE n.Id = a.Id
          AND n.category = 'Notes Pertaining to DAR'
          AND n.endDate IS NULL
    ) AS Notes_Pertaining_to_DAR,
    /* Concatenate all active cagemate IDs into one cell */
    (
        SELECT GROUP_CONCAT(DISTINCT CAST(h.roommateId AS VARCHAR), ', ')
        FROM housingRoommatesDivider h
        WHERE h.Id = a.Id
          AND h.removalDate IS NULL
          AND h.roommateEnd IS NULL
          AND h.roommateId IS NOT NULL
    ) AS Cagemates,
    /* Concatenate all active projects & groups into one cell */
    (
        SELECT GROUP_CONCAT(DISTINCT CAST(d.use AS VARCHAR), ', ')
        FROM housingRoommatesDivider h
                 LEFT JOIN study.demographicsUtilization d ON d.Id = h.roommateId
        WHERE h.Id = a.Id
          AND h.removalDate IS NULL
          AND h.roommateEnd IS NULL
          AND h.roommateId IS NOT NULL
    ) AS Cagemate_Assignments

FROM Assignment a
WHERE
    a.Id.Age.ageinyears <= 2.5
    AND a.project.displayname NOT IN ('0492-02', '0492-03')
    AND a.Id.demographics.species = 'Rhesus Macaque'
    AND EXISTS (
        SELECT 1
        FROM study.Notes n
        WHERE n.Id = a.Id
          AND n.value LIKE '%Assignment pool%'
          AND n.endDate IS NULL
    )


