/*
 * Copyright (c) 2010-2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT
   t.room,
   t.cage,
   t.numCages,
   t.cages,
   t.totalAnimals,
   t.totalWeight,
   t.requiredSqFt,
   t.totalCageSqFt,
   --round((t.requiredSqFt / t.totalCageSqFt) * 100, 1) as sqftPct,
   t.requiredHeight,
   t.minCageHeight,
   --round((t.requiredHeight / t.minCageHeight) * 100, 1) as heightPct,
   t.totalCageRows,
   CASE
     WHEN t.totalCageSqFt < t.requiredSqFt THEN ('Insufficient Sq. Ft, needs at least: ' || cast(t.requiredSqFt as varchar))
     WHEN (t.minCageHeight is not null AND t.minCageHeight < t.requiredHeight) THEN ('Insufficient height, needs at least: ' || cast(t.requiredHeight AS varchar))
     ELSE null
   END as cageStatus,
   t.totalApproachingLimit,
  highs,
  weights

FROM (

SELECT
    pc.room,
    pc.effectiveCage as cage,
    group_concat(DISTINCT pc.cage, ',') as cages,
    count(distinct pc.cage) as numCages,
    count(DISTINCT h.id) as totalAnimals,
    cast(sum(h.Id.MostRecentWeight.MostRecentWeight) as float) as totalWeight,
    min(pc.cage_type.height) as minCageHeight,
    sum(pc.cage_type.sqft) as totalCageSqFt,
    --sum(pc.cage_type.MaxAnimalWeight) as maxAllowable,
    sum(c1.sqft) as requiredSqFt,
    max(c1.height) as requiredHeight,
    count(c1.sqft) as totalCageRows,
    sum(CASE
      WHEN ((h.Id.mostRecentWeight.mostRecentWeight / c1.high) > 0.95) THEN 1
      ELSE 0
    END) as totalApproachingLimit,
         group_concat(c1.high) as highs,
         group_concat(h.Id.mostRecentWeight.mostRecentWeight) as weights
FROM ehr_lookups.pairedCages pc

JOIN study.housing h ON (h.room = pc.room AND pc.cage = h.cage AND h.enddateTimeCoalesced >= now())
LEFT JOIN ehr_lookups.cageclass c1 ON (c1.low <= h.Id.mostRecentWeight.mostRecentWeight AND h.Id.mostRecentWeight.mostRecentWeight < c1.high)

GROUP BY pc.room, pc.effectiveCage

) t