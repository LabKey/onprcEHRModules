/*
 * Copyright (c) 2015 LabKey Corporation
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0

 Created by Kolli on Nov 1st, 2021
 Create an alert to show the following fasting procedures prescribed on the current day between 16:00 - 7:30Am (4pm to 8am)
 1. Complete NPO - 2440
 2. Overnight Fast - 1807
 3. AM Fast - 1804
*/
Select
    Id,
    date,
    enddate,
    project.displayName as project,
    chargetype,
    procedureid.name as procedurename,
    instructions,
    remark,
    performedby,
    taskid,
    QCState.label as status
    /*hour(date),
    minute(date),
    year(date),year(now()),
    month(date),month(now()),
    dayofmonth(date),dayofmonth(now()),
    curdate() */
From encounters
Where procedureid in (1804,1807,2440) -- get these procedures only
  And year(date) = year(now())  -- get today
  And month(date) = month(now())
  And dayofmonth(date) = dayofmonth(now())
  And ((hour(date) >= 17 and hour(date) <= 24 ) OR (hour(date) >= 1 and hour(date) <= 8)) -- 4pm to 8am
--And CAST(date AS TIME) between '16:00' And '7:30'
