SELECT
    a.Id,
    a.Id.demographics.gender AS Sex,
    a.Id.Age.ageinyears,
    a.Id.curlocation.room AS Room,
    a.Id.curlocation.cage AS Cage,
    a.project,
    a.project.protocol.displayname AS Protocol,
    a.project.title AS Title,
    a.project.protocol.investigatorId.lastname AS ProjectInvestigator,
    CAST(a.date AS DATE) AS AssignDate,
    CAST(a.enddate AS DATE) AS ReleaseDate,
    CAST(a.projectedRelease AS DATE) AS ProjectedReleaseDate,
    a.assignmentType,
    a.projectedReleaseCondition.meaning AS ProjectedReleaseCondition,
    a.releaseCondition.meaning AS ConditionAtRelease,
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
  AND a.Id.demographics.species = 'Rhesus Macaque'
  AND a.enddate IS NULL
  AND a.isActive = 1
  AND a.project.displayname NOT IN ('0492-02', '0492-03')





















-- SELECT
--     a.Id,
--     a.Id.demographics.gender AS Sex,
--     a.Id.Age.ageinyears,
--     a.Id.curlocation.room AS Room,
--     a.Id.curlocation.cage AS Cage,
--     a.project,
--     a.project.protocol.displayname AS Protocol,
--     a.project.title AS Title,
--     a.project.protocol.investigatorId.lastname AS ProjectInvestigator,
--     CAST(a.date AS DATE) AS AssignDate,
--     CAST(a.enddate AS DATE) AS ReleaseDate,
--     CAST(a.projectedRelease AS DATE) AS ProjectedReleaseDate,
--     a.assignmentType,
--     a.projectedReleaseCondition.meaning AS ProjectedReleaseCondition,
--     a.releaseCondition.meaning AS ConditionAtRelease,
--     h.roommateId AS Cagemate,
--     d.use AS Cagemate_Assignment
-- FROM Assignment a
--     LEFT JOIN housingRoommatesDivider h
--         ON h.Id = a.Id
--         AND h.removalDate IS NULL
--         AND h.roommateEnd IS NULL
--     LEFT JOIN study.demographicsUtilization d
--         ON d.Id = h.roommateId
-- WHERE
--     a.Id.Age.ageinyears <= 2.5
--     AND a.Id.demographics.species = 'Rhesus Macaque'
--     AND a.enddate IS NULL
--     AND a.isActive = 1
--     AND a.project.displayname NOT IN ('0492-02', '0492-03')
