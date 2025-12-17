SELECT
    Id,
    Id.demographics.gender as Sex,
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
    releaseCondition.meaning as ConditionAtRelease

FROM Assignment
WHERE date >= TIMESTAMPADD('SQL_TSI_DAY', 1, NOW())
  AND date <  TIMESTAMPADD('SQL_TSI_DAY', 14, NOW())