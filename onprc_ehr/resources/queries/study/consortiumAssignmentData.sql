/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

PARAMETERS(StartDate TIMESTAMP, EndDate TIMESTAMP)

SELECT
  ao.Id,
  cast(ao.date as timestamp) as date,
  group_concat(DISTINCT f.flag.value, chr(10)) as spfStatus,
  ao.project,

  --overlapping projects
  group_concat(DISTINCT a.project.displayName, chr(10)) as overlappingProjects,
  group_concat(DISTINCT a.project.use_category, (',' || chr(10))) as utilization,

  sum(CASE WHEN (a.project.use_category = 'Research') THEN 1 ELSE 0 END) as totalResearchAssignments,
  sum(CASE WHEN (a.project.use_category = 'U42') THEN 1 ELSE 0 END) as isU42,
  sum(CASE WHEN (a.project.use_category = 'U24') THEN 1 ELSE 0 END) as isU24

FROM study.assignmentOverlaps ao

--add other assignments on the start date
LEFT JOIN study.assignment a ON (
  ao.Id = a.Id AND
  a.dateOnly <= CAST(ao.date as DATE) AND
  a.enddateCoalesced >= CAST(ao.date as DATE)
)

--SPF status at the time
LEFT JOIN study.flags f ON (
  ao.Id = f.Id AND
  f.dateOnly <= CAST(ao.date as DATE) AND
  f.enddateCoalesced >= CAST(ao.date as DATE) AND
  f.flag.category = 'SPF'
)

GROUP BY ao.lsid, ao.Id, ao.date, ao.project