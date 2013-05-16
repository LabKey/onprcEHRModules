/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  d.Id AS Id,

  T1.MostRecentArrival,
  T1.EarliestArrival,
  d.birth,
  coalesce(T1.EarliestArrival, d.birth) as Center_Arrival,

  CASE
    WHEN T1.EarliestArrival IS NULL AND d.birth IS NOT NULL THEN true
    ELSE false
  END as fromCenter,

  CASE
    WHEN T1.EarliestArrival IS NULL AND d.birth IS NOT NULL THEN 'Born At Center'
    ELSE 'External'
  END as type,
  t2.source,

FROM study.demographics d

LEFT JOIN
  (select T1.Id, max(T1.date) as MostRecentArrival, min(T1.date) as EarliestArrival FROM study.arrival T1 WHERE T1.qcstate.publicdata = true GROUP BY T1.Id) T1
  ON (T1.Id = d.Id)

LEFT JOIN study.arrival T2 ON (t2.id = d.id AND t2.date = t1.earliestArrival)

