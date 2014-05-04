/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

PARAMETERS(StartDate TIMESTAMP, EndDate TIMESTAMP)

SELECT
  b.Id,
  max(b.birth) as birth,
  max(b.bornDead) as bornDead,
  max(b.diedBeforeOneYear) as diedBeforeOneYear,

  group_concat(DISTINCT f.flag.value, chr(10)) as spfStatus,
  group_concat(DISTINCT a.project.displayName, chr(10)) as projects,
  group_concat(DISTINCT a.project.title, chr(10)) as projectTitles,
  group_concat(DISTINCT a.project.use_category, chr(10)) as utilization,
  group_concat(DISTINCT a.project.investigatorId.lastName, chr(10)) as investigators,
  group_concat(DISTINCT a.project.investigatorId.division, chr(10)) as divisions,
  count(a.lsid) as totalAssignments,
  sum(CASE WHEN a.project.use_category = 'Research' THEN 1 ELSE 0 END) as totalResearchAssignments,
  sum(CASE WHEN a.project.use_category = 'U42' THEN 1 ELSE 0 END) as isU42,
  sum(CASE WHEN a.project.use_category = 'U24' THEN 1 ELSE 0 END) as isU24,

FROM study.birthRateData b

--add assignment at the time
LEFT JOIN study.assignment a ON (
  b.Id = a.Id AND
  a.dateOnly <= CAST(timestampadd('SQL_TSI_DAY', 30, b.birth) as date) AND
  a.enddateCoalesced >= CAST(b.birth as date)
)

--SPF status at the time
LEFT JOIN study.flags f ON (
  b.Id = f.Id AND
  f.dateOnly <= CAST(timestampadd('SQL_TSI_DAY', 30, b.birth) as date) AND
  f.enddateCoalesced >= CAST(b.birth as date) AND
  f.flag.category = 'SPF'
)

GROUP BY b.Id, b.birth