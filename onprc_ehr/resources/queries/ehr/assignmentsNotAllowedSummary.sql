SELECT
  a.protocol,
  count(*) as total

FROM ehr.assignmentsNotAllowed a
GROUP BY a.protocol