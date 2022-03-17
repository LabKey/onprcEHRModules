/*
 * Copyright (c) 2015 LabKey Corporation
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0

 Created by Kolli on Nov 1st, 2021
 Create an alert to show the following fasting procedures prescribed on the current day between 16:00 thru 8am following day
 1. Complete NPO - 2440
 2. Overnight Fast - 1807
 3. AM Fast - 1804
*/

Select
    Id,
    id.curLocation.room + ' ' +  id.curLocation.cage as location,
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

From encounters
Where procedureid in (1804,1807,2440, 3089) -- get these procedures only
 And (date < cast(TimeStampAdd('SQL_TSI_DAY',1,cast(cast(now() as date) as varchar(30)) + ' ' + '08:00') as TIMESTAMP)
  And date > cast(cast(cast(now() as date) as varchar(30)) + ' ' + '16:00' as TIMESTAMP)  )  ---Between 4pm thru 8am
  And instructions not in ('Lab staff will pull chow and wash caging')
  And type = 'Procedure'

