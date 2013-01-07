/*
 * Copyright (c) 2010-2011 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

PARAMETERS(STARTDATE TIMESTAMP, ENDDATE TIMESTAMP)

SELECT
    i.date,
    h.id,
    h.project,
    h.project.protocol as protocol,
    h.project.account as account,
    count(*) as totalAssignmentRecords,
    1.0 / count(*) as effectiveDays,
    group_concat(DISTINCT h2.project) as overlappingProjects,
    group_concat(DISTINCT h2.project.protocol) as overlappingProtcols,
    group_concat(DISTINCT h3.room) as rooms,
    group_concat(DISTINCT h3.cage) as cages
FROM (
  --generate one row per day over the selected range
  SELECT
    timestampadd('SQL_TSI_DAY', i.value, CAST(COALESCE(STARTDATE, curdate()) AS TIMESTAMP)) as date
  FROM ldk.integers i
  WHERE i.value <= TIMESTAMPDIFF('SQL_TSI_DAY', CAST(COALESCE(ENDDATE, curdate()) AS TIMESTAMP), CAST(COALESCE(STARTDATE, curdate()) AS TIMESTAMP))
  ) i

LEFT JOIN (
  --join to any assignment record overlapping each day
  SELECT
    h.lsid,
    h.id,
    h.project,
    h.project.account,
    h.date,
    h.ENDDATE
  FROM study.assignment h

  WHERE (
    (cast(COALESCE(STARTDATE, '1900-01-01') AS TIMESTAMP) >= cast(h.date as date) AND cast(COALESCE(STARTDATE, '1900-01-01') AS TIMESTAMP) <= COALESCE(cast(h.enddate as date), curdate()))
  OR
    (COALESCE(ENDDATE, curdate()) >= cast(h.date as date) AND COALESCE(ENDDATE, curdate()) <= COALESCE(cast(h.enddate as date), curdate()))
  OR
    (cast(COALESCE(STARTDATE, '1900-01-01') AS TIMESTAMP) <= cast(h.date as date) AND COALESCE(ENDDATE, curdate()) >= COALESCE(cast(h.enddate as date), curdate()))
  ) AND h.qcstate.publicdata = true

) h ON (i.date >= cast(h.date as date) AND i.date <= COALESCE(cast(h.enddate as date), curdate()))

LEFT JOIN (
  --for each assignment, find co-assigned projects on that day
  SELECT
    h.lsid,
    h.date,
    h.enddate,
    h.id,
    h.project,
    h.project.account
  FROM study.assignment h

  WHERE (
    (cast(COALESCE(STARTDATE, '1900-01-01') AS TIMESTAMP) >= h.date AND cast(COALESCE(STARTDATE, '1900-01-01') AS TIMESTAMP) < COALESCE(h.enddate, curdate()))
  OR
    (COALESCE(ENDDATE, curdate()) > h.date AND COALESCE(ENDDATE, curdate()) <= COALESCE(h.enddate, curdate()))
  OR
    (cast(COALESCE(STARTDATE, '1900-01-01') AS TIMESTAMP) <= h.date AND COALESCE(ENDDATE, curdate()) >= COALESCE(h.enddate, curdate()))
  ) AND h.qcstate.publicdata = true
) h2 ON (h.id = h2.id AND h.date >= h2.date AND h.date < COALESCE(h2.enddate, curdate()) AND h.lsid != h2.lsid)

--find housing at the time
LEFT JOIN study.housing h3 ON (
  h.id = h3.id AND h3.qcstate.publicdata = true AND CONVERT(h3.date, DATE) <= i.date AND CONVERT(h3.enddateCoalesced, DATE) >= i.date
)

GROUP BY i.date, h.id, h.project, h.project.account, h.project.protocol