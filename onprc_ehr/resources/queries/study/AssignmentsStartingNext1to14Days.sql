/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/* Created by Kollil, Dec, 2025
   Tkt # 13618
   Priority 4: Add links to grids 3 and 4 in daily Behavior Alerts email (do not need to display full grid in email)
    - for grid 4 - There are __ assignments starting in the Next 1-14 days" with a link, including today's date
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
WHERE CAST(date AS DATE) >= TIMESTAMPADD('SQL_TSI_DAY', 1, CAST(NOW() AS DATE))
  AND CAST(date AS DATE) <=  TIMESTAMPADD('SQL_TSI_DAY', 14, CAST(NOW() AS DATE))