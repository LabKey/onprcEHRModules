/*
 * Copyright (c) 2010-2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT
  t.*,
  CASE
    WHEN t.overlappingProjects IS NULL then 1
    WHEN t.project IS NULL AND t.overlappingProjects IS NOT NULL THEN 0
    WHEN t.ProjectType != 'Research' and t.overlappingProjectsCategory LIKE '%Research%' Then 0
    WHEN t.ProjectType != 'Research' and t.overlappingProjectsCategory NOT LIKE '%Research%' Then (1.0 / (t.totalOverlappingProjects + 1))
    WHEN t.ProjectType = 'Research' and t.overlappingProjectsCategory NOT LIKE '%Research%' Then 1
    WHEN t.ProjectType = 'Research' and t.overlappingProjectsCategory LIKE '%Research%' Then (1.0 / (t.totalOverlappingResearchProjects + 1))
    ELSE 1
  END as effectiveDays

FROM (

SELECT
    i.date,
    i.dateOnly @hidden,
    h3.id,
    h.project,
    h.project.protocol as protocol,
    h.project.account as account,
    max(h.duration) as duration,  --should only have 1 value, no so need to include in grouping
    h.project.use_Category as ProjectType,
    count(*) as totalAssignmentRecords,
    --1.0 / (count(h2.project) + 1) as effectiveDays,
    group_concat(DISTINCT h2.project.displayName) as overlappingProjects,
    count(DISTINCT h2.project) as totalOverlappingProjects,
    count(DISTINCT CASE WHEN h2.project.use_Category = 'Research' THEN 1 ELSE 0 END) as totalOverlappingResearchProjects,
    group_concat(DISTINCT h2.project.use_category) as overlappingProjectsCategory,
    group_concat(DISTINCT h2.project.protocol) as overlappingProtocols,
    group_concat(DISTINCT h3.room) as rooms,
    group_concat(DISTINCT h3.cage) as cages,
    group_concat(DISTINCT h3.room.housingCondition.value) as housingConditions,
    group_concat(DISTINCT h3.room.housingType.value) as housingTypes,
    group_concat(DISTINCT pdf.chargeId) as chargeId,
    min(i.startDate) as startDate @hidden,
    min(i.numDays) as numDays @hidden,
FROM ehr_lookups.dateRange i

-- find any animal that was housed here on each day.  this was moved to be the
-- first join so we can be sure to include any animal housed here on that day,
-- as opposed to only assigned animals
JOIN study.housing h3 ON (
  -- housing is a little tricky.  assignments are considered to happen in whole-day increments, but
  -- housing is date/time.  therefore we can find situations where the two might not align,
  -- but it is really difficult to guess which is the correct type.  by convention, we take the housing
  -- for the animal at 23:59 of the day in question.  this is important so we are certain is happens after start of assignment
  -- Using midnight would not do this.  1439 is one minute less than a full day
  h3.date <= TIMESTAMPADD('SQL_TSI_MINUTE', 1439, CONVERT(i.date, timestamp))
  AND h3.enddatetimeCoalesced >= TIMESTAMPADD('SQL_TSI_MINUTE', 1439, CONVERT(i.date, timestamp))
  AND h3.qcstate.publicdata = true
)

--then join to any assignment record overlapping each day
LEFT JOIN (
  SELECT
    h.lsid,
    h.id,
    h.project,
    h.project.account,
    h.date,
    h.assignCondition,
    h.releaseCondition,
    h.projectedReleaseCondition,
    h.duration,
    h.enddate,
    h.dateOnly,
    h.enddateCoalesced
  FROM study.assignment h

  WHERE h.qcstate.publicdata = true
    --NOTE: we might want to exclude 1-day assignments, or deal with them differently
    --AND h.duration > 0

) h ON (
    h3.Id = h.id AND
    h.dateOnly <= i.date
    --assignments end at midnight, so an assignment doesnt count on the current date if it ends on it
    --NOTE: we do need to capture 1-day assignments, so these do count if the start and end are the same day
    AND (h.enddate IS NULL OR h.enddateCoalesced > i.dateOnly OR (h.dateOnly = i.dateOnly AND h.enddateCoalesced = i.dateOnly))
  )

LEFT JOIN (
  --for each assignment, find co-assigned projects on that day
  SELECT
    h.lsid,
    h.date,
    h.enddate,
    h.id,
    h.project,
    h.project.account,
    h.dateOnly,
    h.enddateCoalesced
  FROM study.assignment h
  WHERE
    --exclude 1-day assignments
    h.duration > 1
    AND h.qcstate.publicdata = true
) h2 ON (
  h3.id = h2.id
  AND h2.dateOnly <= i.dateOnly
  AND h.project != h2.project
  --assignments end at midnight, so an assignment doesnt count on the current date if it ends on it
  --we also need to include 1-day assignments
  AND (h2.enddate IS NULL OR h2.enddateCoalesced > i.dateOnly OR (h2.dateOnly = i.dateOnly AND h2.enddateCoalesced = i.dateOnly))
  AND h.lsid != h2.lsid
)

LEFT JOIN onprc_billing.perDiemFeeDefinition pdf
ON (
  pdf.housingType = h3.room.housingType AND
  pdf.housingDefinition = h3.room.housingCondition AND
  (pdf.releaseCondition = h.releaseCondition OR pdf.releaseCondition is null)
)

GROUP BY i.date, i.dateOnly, h3.Id, h.project, h.project.account, h.project.protocol, h.project.use_Category

) t