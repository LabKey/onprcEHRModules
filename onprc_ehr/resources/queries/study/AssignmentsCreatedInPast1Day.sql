/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/* Created by Kollil, Dec, 2025
   Tkt # 13618
   Priority 1: Add Grid 1 ("Assignments Created in the Past Day ") to daily Behavior Alerts email - display full grid in email
 */
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
WHERE CAST(created AS DATE) >= TIMESTAMPADD('SQL_TSI_DAY', -1, CAST(NOW() AS DATE))