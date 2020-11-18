/*
 * Copyright (c) 2011 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

  /*   Created  Blasa    2-6-2015  Provide most SLA Census   Modified 8-28-2015 */

select
    a.project AS project,
    a.Investigatorid AS Investigator,
    rtrim(a.room) AS room,
    a.species AS Species,
    a.cagetype AS Cage_Type,
    a.cageSize AS Cage_Size,
    a.date AS Date,
    CASE WHEN a.cagecount = 0 THEN 0 ELSE a.animalcount END AS Animal_Count,
    a.cagecount AS Cage_Count,
    now() AS recentdate
from  sla.census a

Where a.date in (select max(b.date) from  sla.census b where  a.project = b.project
And a.species = b.species and a.cageSize = b.cageSize and a.Cagetype = b.cageType and a.room = b.room and b.cagecount >0 AND timestampdiff('SQL_TSI_DAY', b.date, now())  <  6)
And  timestampdiff('SQL_TSI_DAY', a.date, now())  <  6



group by a.project, a.Investigatorid, a.species, a.cagetype, a.cageSize, a.room,a.date,a.animalcount, a.cagecount
order by   a.room  , a.date desc