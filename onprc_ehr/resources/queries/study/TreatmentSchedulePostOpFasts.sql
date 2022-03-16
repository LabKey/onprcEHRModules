/*
 * Copyright (c) 2015 LabKey Corporation
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0

 Created by Kolli on Nov 1st, 2021
 Create an alert to show the following fasting procedures prescribed on the current day between 16:00 thru 8am following day
 1. Complete NPO - 2440
 2. Overnight Fast - 1807
 3. AM Fast - 1804

Changes made by Kolli on Mar 8th, 2022
    Carly requested the following changes
    1. Remove the "Performed by" for all the alerts.
    2. Is there an option to show who requested it and their contact information? - Yes, I can add that
    3. Can we remove the column of charge unit in the alert as well? - Yes, I will remove the chargeunit field.
    4. Added First contact, Second contact, Third Contact and Created, Created By annd Lab Phone num from ehr.requests table

*/
Select
    e.Id,
    e.Id.curLocation.room + ' ' +  e.id.curLocation.cage as location,
    e.date,
    e.enddate,
    e.project.name as project,
    e.procedureid.name as procedurename,
    e.instructions,
    e.remark,
    r.notify1 as FirstContact,
    r.notify2 as SecondContact,
    r.notify3 as ThirdContact,
    r.created,
    r.createdby,
    r.remark as LabPhoneNum,
    e.QCState.label as status
From encounters e, ehr.requests r
Where
e.requestid = r.requestid
And procedureid in (1804,1807,2440, 3089) -- get these procedures only
And (date < cast(TimeStampAdd('SQL_TSI_DAY',1,cast(cast(now() as date) as varchar(30)) + ' ' + '08:00') as TIMESTAMP)
And date > cast(cast(cast(now() as date) as varchar(30)) + ' ' + '16:00' as TIMESTAMP)  )  ---Between 4pm thru 8am
And instructions not in ('Lab staff will pull chow and wash caging')
And type = 'Procedure'

