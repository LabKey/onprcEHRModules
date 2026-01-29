SELECT
    a.Id,
    a.Id.demographics.gender AS Sex,
    a.Id.Age.ageinyears,
    a.Id.curlocation.room AS Room,
    a.Id.curlocation.cage AS Cage,
    a.project.displayname AS project,
    a.project.protocol.displayname AS Protocol,
    a.project.title AS Title,
    a.project.protocol.investigatorId.lastname AS ProjectInvestigator,
    CAST(a.date AS DATE) AS AssignDate,
    CAST(a.enddate AS DATE) AS ReleaseDate,
    CAST(a.projectedRelease AS DATE) AS ProjectedReleaseDate,
    a.assignmentType,
    a.projectedReleaseCondition.meaning AS ProjectedReleaseCondition,
    a.releaseCondition.meaning AS ConditionAtRelease,

    /* Display the (active) Notes Pertaining to DAR note text */
    (
        SELECT MAX(n.value)
        FROM study.Notes n
        WHERE n.Id = a.Id
          AND n.category = 'Notes Pertaining to DAR'
          AND n.endDate IS NULL
    ) AS Notes_Pertaining_to_DAR,

    h.roommateId AS Cagemate,
    d.use AS Cagemate_Assignment

FROM Assignment a
    LEFT JOIN housingRoommatesDivider h
        ON h.Id = a.Id
        AND h.removalDate IS NULL
        AND h.roommateEnd IS NULL
    LEFT JOIN study.demographicsUtilization d
        ON d.Id = h.roommateId
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


