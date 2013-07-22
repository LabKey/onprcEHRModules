/*
 * Copyright (c) 2010-2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT
   t.room,
   t.cage,
   jc.numCages,
   jc.cages,
   jc.cageTypes,
   t.totalAnimals,
   t.distinctAnimals,
   t.weights,
   t.totalWeight,
   t.rawWeight,
   jc.totalSqFt,
   t.requiredSqFt,
   t.requiredSqFtIncluding5Mo,
   t.requiredHeight,
   t.minCageHeight,
   CASE
     WHEN jc.totalSqFt < t.requiredSqFt THEN ('ERROR: Insufficient Sq. Ft, needs at least: ' || cast(t.requiredSqFt as varchar))
     WHEN (t.minCageHeight is not null AND t.minCageHeight < t.requiredHeight) THEN ('ERROR: Insufficient height, needs at least: ' || cast(t.requiredHeight AS varchar))
     WHEN jc.totalSqFt < t.requiredSqFtIncluding5Mo THEN ('WARNING: When including 5 month olds, insufficient Sq. Ft, needs at least: ' || cast(t.requiredSqFtIncluding5Mo as varchar))
     ELSE null
   END as cageStatus,
   t.totalApproachingLimit,
   t.heights

FROM (

SELECT
    pc.room,
    pc.effectiveCage as cage,
    count(DISTINCT h.id) as totalAnimals,
    SUM(CASE WHEN h.Id.age.ageInMonths >= 6.0 THEN 0 ELSE 1 END) as totalAnimalsUnder6Mo,
    SUM(CASE WHEN h.Id.age.ageInMonths = 5.0 THEN 0 ELSE 1 END) as totalAnimals5MonthsOld,
    group_concat(DISTINCT h.id, chr(10)) as distinctAnimals,
    cast(sum(CASE
      WHEN h.Id.age.ageInMonths >= 6.0 THEN h.Id.MostRecentWeight.MostRecentWeight
      ELSE 0
    END) as float) as totalWeight,
    cast(sum(h.Id.MostRecentWeight.MostRecentWeight) as float) as rawWeight,
    min(pc.cage_type.height) as minCageHeight,

    sum(CASE WHEN (h.Id.age.ageInMonths >= 6.0) THEN c1.sqft ELSE 0.0 END) as requiredSqFt,
    sum(CASE WHEN (h.Id.age.ageInMonths >= 5.0) THEN c1.sqft ELSE 0.0 END) as requiredSqFtIncluding5Mo,
    sum(c1.sqft) as requiredSqFtForAll,
    max(c1.height) as requiredHeight,
    sum(CASE
      WHEN ((h.Id.mostRecentWeight.mostRecentWeight / c1.high) > 0.95) THEN 1
      ELSE 0
    END) as totalApproachingLimit,
    group_concat(c1.high) as heights,
    group_concat(h.Id.mostRecentWeight.mostRecentWeight) as weights
FROM ehr_lookups.connectedCages pc

JOIN study.housing h ON (h.room = pc.room AND pc.cage = h.cage AND h.enddateTimeCoalesced >= now())
LEFT JOIN ehr_lookups.cageclass c1 ON (c1.low <= h.Id.mostRecentWeight.mostRecentWeight AND h.Id.mostRecentWeight.mostRecentWeight < c1.high)

GROUP BY pc.room, pc.effectiveCage

) t

LEFT JOIN ehr_lookups.connectedCageSummary jc ON (t.cage = jc.effectiveCage AND t.room = jc.room)