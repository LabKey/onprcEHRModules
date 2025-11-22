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
    assignCondition.meaning as AssignCondition,
    projectedReleaseCondition.meaning as ProjectedReleaseCondition,
    releaseCondition.meaning as ConditionAtRelease

FROM Assignment
WHERE date >= TIMESTAMPADD('SQL_TSI_DAY', -1, NOW())
  AND date <  TIMESTAMPADD('SQL_TSI_DAY', -7, NOW())