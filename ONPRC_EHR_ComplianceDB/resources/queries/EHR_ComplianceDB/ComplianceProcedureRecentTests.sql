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

       (Select group_concat(distinct yy.comment, chr(10))  from completiondates yy where yy.date in (select max(zz.date) from completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid )
                                                                                     And  yy.requirementname= b.requirementname and yy.employeeid= a.employeeid   ) as comment,

       CAST(
               CASE

                   WHEN (select max(st.date) from completiondates st where st.requirementname = b.requirementname and st.employeeid = a.employeeid ) IS NULL   then 0
                   WHEN ( select  (tt.expireperiod)  from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod  ) = 0 then Null

                   ELSE ( select  (tt.expireperiod) - ( age_in_months(max(pq.date), curdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod  )
                   END  AS double)  AS MonthsUntilRenewal



from employeeperunit a ,requirementspercategory b
where ( a.unit = b.unit or a.category = b.category )

group by b.requirementname,a.employeeid


union


select a.requirementname,
       a.employeeid,
       null,
       null,
       'No' as trackingflag,


       (select count(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid  ) as timesCompleted,

       (select k.expireperiod from ehr_compliancedb.Requirements k where k.requirementname = a.requirementname) as ExpiredPeriod,

       (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid  ) as MostRecentDate,

       (Select group_concat(distinct yy.comment, chr(10))  from completiondates yy where yy.date in (select max(zz.date) from completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid )
                                                                                     And  yy.requirementname= a.requirementname and yy.employeeid= a.employeeid   ) as comment,

       CAST(

               CASE

                   WHEN (select max(st.date) from completiondates st where st.requirementname = a.requirementname and st.employeeid = a.employeeid ) IS NULL   then 0
                   WHEN ( select  (tt.expireperiod)  from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod  ) = 0 then Null


                   ELSE ( select  (tt.expireperiod) - ( age_in_months(max(pq.date), curdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod  )
                   END  AS double)  AS MonthsUntilRenewal


from  ehr_compliancedb.completiondates a
where a.requirementname not in (select distinct h.requirementname from ehr_compliancedb.employeeperunit k, ehr_compliancedb.requirementspercategory h Where (k.unit = h.unit
    or k.category = h.category) And a.employeeid = k.employeeid )
  And a.requirementname not in (select distinct t.requirementname from ehr_compliancedb.employeerequirementexemptions t Where a.employeeid = t.employeeid
                                                                                                                          And a.requirementname = t.requirementname)

group by a.requirementname,a.employeeid

