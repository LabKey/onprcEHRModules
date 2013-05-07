/*
 * Copyright (c) 2010-2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  r.room,
  count(DISTINCT c.cage) as TotalCages,
  max(cbr.availableCages) as AvailableCages,
  count(DISTINCT h.cage) as CagesUsed,
  max(cbr.availableCages) - count(DISTINCT h.cage) as CagesEmpty,
  round((CAST(count(DISTINCT h.cage) as double) / cast(max(cbr.availableCages) as double)) * 100, 1) as pctUsed,
  count(DISTINCT h.id) as TotalAnimals,


FROM ehr_lookups.rooms r
LEFT JOIN ehr_lookups.cage c ON (r.room = c.room)
LEFT JOIN study.housing h ON (r.room=h.room AND (c.cage=h.cage OR (c.cage is null and h.cage is null)) AND COALESCE(h.enddate, now()) >= now())
LEFT JOIN ehr_lookups.availableCagesByRoom cbr ON (cbr.room = r.room)
WHERE r.datedisabled is null
GROUP BY r.room

