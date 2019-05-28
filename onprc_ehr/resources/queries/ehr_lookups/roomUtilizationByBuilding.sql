/*
 * Copyright (c) 2010-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  t1.building,
  t1.totalRooms,
  t1.totalCages,
  t1.availableCages,
  t1.cagesUsed,
  t1.cagesEmpty,
  cast(((CAST(t1.cagesUsed as double) / t1.availableCages) * 100) as double) as pctUsed,
  cast((100.0 - ((CAST(t1.cagesUsed as double) / t1.availableCages) * 100)) as double) as pctEmpty,
  t1.totalAnimals

FROM (
SELECT
  r.room.building as building,
  count(DISTINCT r.room) as totalRooms,
  sum(CASE WHEN r.room.housingType.value = 'Cage Location' THEN r.totalCages ELSE null END) as totalCages,
  sum(CASE WHEN r.room.housingType.value = 'Cage Location' THEN r.availableCages ELSE null END) as availableCages,
  sum(CASE WHEN r.room.housingType.value = 'Cage Location' THEN r.cagesUsed ELSE null END) as cagesUsed,
  sum(CASE WHEN r.room.housingType.value = 'Cage Location' THEN r.cagesEmpty ELSE null END) as cagesEmpty,
  sum(r.totalAnimals) as totalAnimals

FROM ehr_lookups.roomUtilization r
GROUP BY r.room.building

) t1