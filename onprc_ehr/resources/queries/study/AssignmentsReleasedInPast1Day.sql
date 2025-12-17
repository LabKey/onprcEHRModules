SELECT
    Id,
    Id.demographics.gender as Sex,
    Id.curlocation.room as Room,
    Id.curlocation.cage as Cage,
    project.displayname as project,
    project.protocol.displayname as Protocol,
    project.title as Title,
    project.protocol.investigatorId.lastname as ProjectInvestigator,
    date as AssignDate,
    enddate as ReleaseDate,
    projectedrelease as ProjectedReleaseDate,
    assignmentType,
    assignCondition.meaning as AssignCondition,
    projectedReleaseCondition.meaning as ProjectedReleaseCondition,
    releaseCondition.meaning as ConditionAtRelease

FROM Assignment
WHERE enddate >= TIMESTAMPADD('SQL_TSI_DAY', -1, NOW())