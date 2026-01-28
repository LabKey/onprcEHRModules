SELECT
    Id,
    Id.demographics.gender as Sex,
    Id.Age.ageinyears,
    Id.curlocation.room as Room,
    Id.curlocation.cage as Cage,
    project.displayname as project,
    project.protocol.displayname as Protocol,
    project.title as Title,
    project.protocol.investigatorId.lastname as ProjectInvestigator,
    CAST(date AS DATE) AS AssignDate,
    CAST(enddate AS DATE) AS ReleaseDate,
    CAST(projectedRelease AS DATE) AS ProjectedReleaseDate,
    assignmentType,
    assignCondition.meaning as AssignCondition,
    projectedReleaseCondition.meaning as ProjectedReleaseCondition,
    releaseCondition.meaning as ConditionAtRelease,
    /* Display the (active) Assignment pool note text */
    (
        SELECT MAX(n.value)
        FROM study.Notes n
        WHERE n.Id = Assignment.Id
          AND n.value LIKE '%Assignment pool%'
          AND n.endDate IS NULL
    ) AS BSU_Notes
FROM Assignment
WHERE Id.Age.ageinyears <= 2.5
    AND enddate IS NULL
    AND
    (
        (
            /* Active assignment, excluding U42/U42E colony maintenance center projects */
            project.displayname NOT IN ('0492-02', '0492-03')
        )
    OR
        /* Has "Assignment pool" note in study.Notes */
        EXISTS (
            SELECT 1
            FROM study.Notes n
            WHERE n.Id = Assignment.Id
            AND n.value LIKE '%Assignment pool%'
            AND n.endDate IS NULL --active
        )
    )