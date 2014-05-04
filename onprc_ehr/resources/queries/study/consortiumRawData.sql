/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

PARAMETERS(StartDate TIMESTAMP, EndDate TIMESTAMP)

SELECT
  t1.*,
  CASE
    WHEN (t1.ageAtTime < 1.0) THEN 1
    ELSE null
  END as isInfant,
  CASE
    WHEN (t1.gender = 'm' AND t1.ageAtTime >= 4.0 ) THEN 1
    ELSE null
  END as isBreedingMale,
  CASE
    WHEN (t1.gender = 'f' AND t1.ageAtTime >= 3.0 ) THEN 1
    ELSE null
  END as isBreedingFemale,
  CASE
    WHEN (t1.gender = 'f' AND t1.ageAtTime >= 1.0 AND t1.ageAtTime < 3.0 ) THEN 1
    WHEN (t1.gender = 'm' AND t1.ageAtTime >= 1.0 AND t1.ageAtTime < 4.0 ) THEN 1
    ELSE null
  END as isJuvenille,

FROM (
SELECT
  t.Id,
  t.Id.demographics.gender as gender,
  StartDate as startDate,
  EndDate as endDate,
  t.projects,
  t.projectTitles,
  t.utilization,
  t.investigators,
  t.divisions,
  t.totalAssignments,
  t.totalResearchAssignments,
  CASE WHEN (t.isCaged > 0) THEN 1 ELSE 0 END as isCaged,
  CASE WHEN (t.totalAssignments = 0) THEN 1 ELSE null END as isP51,
  CASE
    WHEN (t.isU42 > 0 AND t.isU42 = t.totalAssignments) THEN 1
    ELSE null
  END as isU42,
  CASE
    WHEN (t.isU24 > 0 AND t.isU24 = t.totalAssignments) THEN 1
    ELSE null
  END as isU24,
  t.spfStatus,
  ROUND(CONVERT(age_in_months(t.Id.demographics.birth, COALESCE(t.Id.demographics.death, now())), DOUBLE) / 12, 1) as ageAtTime
FROM (
SELECT
  h.Id,
  group_concat(DISTINCT a.project.displayName, chr(10)) as projects,
  group_concat(DISTINCT a.project.title, chr(10)) as projectTitles,
  group_concat(DISTINCT a.project.use_category, chr(10)) as utilization,
  group_concat(DISTINCT a.project.investigatorId.lastName, chr(10)) as investigators,
  group_concat(DISTINCT a.project.investigatorId.division, chr(10)) as divisions,
  count(a.lsid) as totalAssignments,
  sum(CASE WHEN (h.room.housingType.value = 'Cage Location' AND h.room.area != 'Hospital') THEN 1 ELSE 0 END) as isCaged,
  sum(CASE WHEN a.project.use_category = 'Research' THEN 1 ELSE 0 END) as totalResearchAssignments,
  sum(CASE WHEN a.project.use_category = 'U42' THEN 1 ELSE 0 END) as isU42,
  sum(CASE WHEN a.project.use_category = 'U24' THEN 1 ELSE 0 END) as isU24,
  group_concat(DISTINCT f.flag.value, chr(10)) as spfStatus,

FROM study.housingOverlaps h

--add assignment at the time
LEFT JOIN study.assignment a ON (
  h.Id = a.Id AND
  a.dateOnly <= CAST(EndDate as date) AND
  a.enddateCoalesced >= CAST(StartDate as date)
)

--SPF status at the time
LEFT JOIN study.flags f ON (
  h.Id = f.Id AND
  f.dateOnly <= CAST(EndDate as date) AND
  f.enddateCoalesced >= CAST(StartDate as date) AND
  f.flag.category = 'SPF'
)

GROUP BY h.Id

) t

) t1