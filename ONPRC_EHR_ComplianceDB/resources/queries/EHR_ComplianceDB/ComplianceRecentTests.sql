/*
 * Copyright (c) 2010-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

-- Created: 10-6-2021   R.Blasa     ComplianceRecentTests.sql

select b.requirementname,
       a.employeeid,
       group_concat(distinct b.unit,chr(10)) as unit,
       group_concat(distinct a.category,chr(10)) as category,
       group_concat(distinct b.trackingflag) as trackingflag,


       (select count(zz.date) from completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid  ) as timesCompleted,

       (select k.expireperiod from Requirements k where k.requirementname = b.requirementname) as ExpiredPeriod,

       (select max(zz.date) from completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid  ) as MostRecentDate,

    CAST(
     (select
         CASE
            WHEN max(pq.date) is null then 0
            WHEN Tr.expireperiod = 0 then null
            ELSE ( Tr.expireperiod - ( age_in_months(max(pq.date), curdate()))  )
        END  from completiondates pq, requirements Tr where pq.requirementname = b.requirementname And Tr.requirementname = pq.requirementname and pq.employeeid = a.employeeid group by tr.expireperiod) AS double)
         AS MonthsUntilRenewal


from employeeperunit a ,requirementspercategory b
where ( a.unit = b.unit or a.category = b.category )

group by b.requirementname,a.employeeid