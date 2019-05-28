/*
 * Copyright (c) 2010-2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT

d2.id,

CASE
  WHEN d2.cage is null then d2.room
  ELSE (d2.room || '-' || d2.cage)
END AS Location,

d2.room.area,

d2.room,

d2.cage,

d2.date,

d2.cagePosition,

coalesce(d2.room.sort_order, 0) as room_order,
room_sortValue @hidden,

coalesce(d2.cagePosition.sort_order, 0) AS cage_order,
cage_sortValue @hidden,

d2.daysInRoom,
d2.daysInArea,
d2.previousLocation.location as prevLocation,
d2.previousLocation.room as prevRoom,
d2.previousLocation.cage as prevCage

FROM study.housing d2

WHERE d2.enddate IS NULL
AND d2.qcstate.publicdata = true