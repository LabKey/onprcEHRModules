/*
 * Copyright (c) 2010-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

-- Modified: 6-14-2022   R.Blasa     ComplianceRecentTests.sql
-- Training that was completed by an employee and being recorded as  completed as a Unit or Category
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


                   WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod
                          having (tt.expireperiod) >  (age_in_months(tt.reviewdate, max(pq.date)) and (tt.reviewdate is not null)  )) > 0 THEN

                       ( select  (age_in_months(max(pq.date), tt.reviewdate) - ( age_in_months(max(pq.date), curdate())) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod
                         having (tt.expireperiod) > (age_in_months(max(pq.date),tt.reviewdate)) and (tt.reviewdate is not null)  )


                   ELSE ( select  (tt.expireperiod) - ( age_in_months(max(pq.date), curdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod )

                   END  AS double)  AS MonthsUntilRenewal




from employeeperunit a ,requirementspercategory b
where ( a.unit = b.unit or a.category = b.category )
  And b.requirementname not in (select distinct t.requirementname from ehr_compliancedb.employeerequirementexemptions t Where a.employeeid = t.employeeid
                                                                                                                          And b.requirementname = t.requirementname)
  And a.employeeid in (select p.employeeid from ehr_compliancedb.employees p where p.enddate is null)


                                group by b.requirementname,a.employeeid


union

-- Training that was completed by an employee but not recorded as being completed as a Unit or Category
select a.requirementname,
       a.employeeid,
       null as unit,
       null as category,
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


                   WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod
                          having (tt.expireperiod) >  (age_in_months(max(pq.date),tt.reviewdate) and (tt.reviewdate is not null)  )) > 0 THEN

                       ( select  (age_in_months(max(pq.date), tt.reviewdate) - ( age_in_months(max(pq.date), curdate())) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod
                         having (tt.expireperiod) > (age_in_months(max(pq.date),tt.reviewdate) and (tt.reviewdate is not null)  ) )


                   ELSE ( select  (tt.expireperiod) - ( age_in_months(max(pq.date), curdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod )

                   END  AS double)  AS MonthsUntilRenewal


from  ehr_compliancedb.completiondates a
where a.requirementname not in (select distinct h.requirementname from ehr_compliancedb.employeeperunit k, ehr_compliancedb.requirementspercategory h Where (k.unit = h.unit
    or k.category = h.category) And a.employeeid = k.employeeid )
  And a.requirementname not in (select distinct t.requirementname from ehr_compliancedb.employeerequirementexemptions t Where a.employeeid = t.employeeid
                                                                                                                          And a.requirementname = t.requirementname)
  And a.employeeid in (select p.employeeid from ehr_compliancedb.employees p where p.enddate is null)

group by a.requirementname,a.employeeid

UNION

-- Additional requirements for employees that have not completed training, but is required
select j.requirementname,
       j.employeeid,
       null as unit,
       null as category,
       'Yes' as trackingflag,
       null as timesCompleted,
       null as ExpiredPeriod,
       null as MostRecentDate,
       '' as comment,
       null AS MonthsUntilRenewal


from  ehr_compliancedb.RequirementsPerEmployee j
Where j.requirementname not in (select z.requirementname from ehr_compliancedb.completiondates z where z.requirementname = j.requirementname
  and z.employeeid = j.employeeid and z.date is not null)
  And j.employeeid in (select p.employeeid from ehr_compliancedb.employees p where p.enddate is null)


group by j.requirementname,j.employeeid





