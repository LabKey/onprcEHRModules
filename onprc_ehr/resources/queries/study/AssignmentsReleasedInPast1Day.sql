/* Created by Kollil, Dec, 2025
   Tkt # 13618
  Priority 2: Create new Grid 2 (Assignments ended in the Past 1 Day):
    - List of records with new “Release date” added within the last 24hrs (omitting day leases). I am not omitting day leases for now as per Isabel's request.
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
WHERE CAST(enddate AS DATE) >= TIMESTAMPADD('SQL_TSI_DAY', -1, NOW())