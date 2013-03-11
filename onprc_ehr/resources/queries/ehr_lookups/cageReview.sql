/*
 * Copyright (c) 2010-2011 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT
   t.room,
   t.cage,
   t.numCages,
   t.cages,
   t.totalWeight,
   t.maxAllowable,
   t.totalAnimals,
   CASE
     WHEN t.totalWeight > t.maxAllowable THEN 'ERROR'
     ELSE null
   END as cageStatus

FROM (

SELECT
    pc.room,
    pc.effectiveCage as cage,
    group_concat(DISTINCT pc.cage, ',') as cages,
    count(distinct pc.cage) as numCages,
    cast(sum(h.Id.MostRecentWeight.MostRecentWeight) as float) as totalWeight,
    sum(pc.cage_type.MaxAnimalWeight) as maxAllowable,
    count(DISTINCT h.id) as totalAnimals,

FROM ehr_lookups.pairedCages pc

LEFT JOIN study.housing h ON (h.room = pc.room AND pc.cage = h.cage AND h.enddateCoalesced >= CAST(now() as date))
GROUP BY pc.room, pc.effectiveCage

) t