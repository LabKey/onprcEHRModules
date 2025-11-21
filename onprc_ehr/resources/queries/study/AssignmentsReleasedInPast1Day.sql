SELECT
    Id,
    Id.demographics.gender as Sex,
    Id.curlocation.room as Room,
    Id.curlocation.cage as Cage,
    project,
    project.protocol as Protocol,
    project.title as Title,
    project.investigatorId as ProjectContact,
    project.protocol.investigatorId as ProjectInvestigator,
    date as AssignDate,
    enddate as ReleaseDate,
    projectedrelease as ProjectedReleaseDate,
    assignmentType,
    assignCondition,
    projectedReleaseCondition,
    releaseCondition as ConditionAtRelease

FROM Assignment
WHERE enddate >= TIMESTAMPADD('SQL_TSI_DAY', -1, NOW())