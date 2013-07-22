/*
 * Copyright (c) 2010-2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

PARAMETERS(STARTDATE TIMESTAMP, ENDDATE TIMESTAMP)

SELECT
    i.date,
    i.dateOnly,
    h.id,
    h.project,
    h.project.protocol as protocol,
    h.project.account as account,
    count(*) as totalAssignmentRecords,
    1.0 / (count(h2.project) + 1) as effectiveDays,
    group_concat(DISTINCT h2.project) as overlappingProjects,
    group_concat(DISTINCT h2.project.protocol) as overlappingProtcols,
    group_concat(DISTINCT h3.room) as rooms,
    group_concat(DISTINCT h3.cage) as cages,
    group_concat(DISTINCT h3.room.housingCondition) as housingConditions,
    group_concat(DISTINCT h3.room.housingType) as housingTypes,
    group_concat(DISTINCT pdf.chargeId) as chargeIds,
FROM ehr_lookups.dateRange i
JOIN (
  --join to any assignment record overlapping each day
  SELECT
    h.lsid,
    h.id,
    h.project,
    h.project.account,
    h.date,
    h.assignCondition,
    h.releaseCondition,
    h.projectedReleaseCondition,
    h.ENDDATE,
    h.dateOnly,
    h.enddateCoalesced
  FROM study.assignment h

  WHERE
    --exclude 1-day assignments
    h.duration > 0
    AND h.qcstate.publicdata = true

) h ON (
    h.dateOnly <= i.date
    --assignments end at midnight, so an assignment doesnt count on the current date if it ends on it
    AND h.enddateCoalesced > i.dateOnly
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
  h.id = h2.id
  AND h2.dateOnly <= i.dateOnly
  --assignments end at midnight, so an assignment doesnt count on the current date if it ends on it
  AND h2.enddateCoalesced > i.dateOnly
  AND h.lsid != h2.lsid
)

--find housing at the time
LEFT JOIN study.housing h3 ON (
  h.id = h3.id
  AND h3.qcstate.publicdata = true
  --base on housing at midnight of that day
  AND h3.date <= CONVERT(i.date, timestamp)
  AND h3.enddatetimeCoalesced >= CONVERT(i.date, timestamp)
)

LEFT JOIN onprc_billing.perDiemFeeDefinition pdf
ON (
  pdf.housingType = h3.room.housingType AND
  pdf.housingDefinition = h3.room.housingCondition AND
  (pdf.releaseCondition = h.releaseCondition OR pdf.releaseCondition is null)
)

GROUP BY i.date, i.dateOnly, h.id, h.project, h.project.account, h.project.protocol