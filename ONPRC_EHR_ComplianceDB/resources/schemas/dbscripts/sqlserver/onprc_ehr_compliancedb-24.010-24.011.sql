

EXEC core.fn_dropifexists 'p_ComplianceProcedureOverDueSoon_Process', 'onprc_ehr_compliancedb', 'PROCEDURE';
GO

-- Author:	R. Blasa
-- Created: 9-20-2024

/*
**
** 	Created by
**      Blasa  		9-20-2024     Created a storedprocedure to create a static set of data from
**                                 the ComplianceProcedureRecentTest.sql query
**
**
**
*/

CREATE Procedure onprc_ehr_compliancedb.p_ComplianceProcedureOverDueSoon_Process


AS


              ----- Reset Reporting table
              Delete onprc_ehr_compliancedb.ComplianceProcedureReport

	                      If @@Error <> 0
	                                GoTo Err_Proc



BEGIN

          Insert into onprc_ehr_compliancedb.ComplianceProcedureReport
                        (
                         requirementname,
                         employeeid,
                         unit,
                         category,
                         trackingflag,
                         email,
                         lastname,
                         firstname,
                         host,
                         supervisor,
                         trainee_type,
                         requirement_name_type,
                         times_completed,
                          expired_period,
                          new_expired_Period,
                          mostrecentcompleted_date,
                          comment,
                          snooze_date,
                          months_until_renewal

                         )





        select b.requirementname,
               a.employeeid,
               string_agg(a.unit,char(10)) as unit,
               string_agg(a.category,char(10)) as category,
               string_agg(b.trackingflag,char(10)) as trackingflag,
              (select h.email from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as  email,
              (select h.lastname from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as lastname,
              (select h.firstname from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as firstname,
              (select h.majorudds from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as host,
              (select h.supervisor from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as supervisor,
              (select h.type from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as trainee_type,      ----- type trainee, or trainer
              (select h.type from ehr_compliancedb.Requirements h where h.requirementname = b.requirementname) as requirement_type,

               (select count(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid  ) as times_Completed,

               (select k.expireperiod from ehr_compliancedb.Requirements k where k.requirementname = b.requirementname) as ExpiredPeriod,

               ( select  (datediff(month,max(pq.date), tt.reviewdate) ) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                 having (COALESCE(tt.expireperiod,0)) > (datediff(month,max(pq.date), tt.reviewdate))   and (tt.reviewdate is not null)  ) as NewExpirePeriod,

               (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid  ) as mostrecentcompleted_date,

               (Select distinct string_agg(yy.comment, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= b.requirementname and yy.employeeid= a.employeeid   ) as comment,

               (Select distinct string_agg(yy.snooze_date, char(10)) from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= b.requirementname and yy.employeeid= a.employeeid   ) as snooze_date,

               CAST(
                       CASE

                           WHEN (select max(st.date) from ehr_compliancedb.completiondates st where st.requirementname = b.requirementname and st.employeeid = a.employeeid ) IS NULL   then 0
                           WHEN ( select (COALESCE(tt.expireperiod,0))  from  ehr_compliancedb.requirements tt where tt.requirementname = b.requirementname   group by tt.expireperiod  ) = 0 then Null


                           WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                  having (tt.reviewdate) >  ( cast(getdate() as date)  )) > 0 THEN

                               ( select  (datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())   ) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                 having (tt.reviewdate) >  ( cast(getdate() as date)   )      )


                           ELSE ( select  (COALESCE(tt.expireperiod,0)) - ( datediff(month,max(pq.date), getdate()) )  from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod )

                           END  AS Float)  AS MonthsUntilRenewal



        from ehr_Compliancedb.employeeperunit a ,ehr_compliancedb.requirementspercategory b
        where ( a.unit = b.unit or a.category = b.category )
          And b.requirementname not in (select distinct t.requirementname from ehr_compliancedb.employeerequirementexemptions t Where a.employeeid = t.employeeid
                                                                                                                                  And b.requirementname = t.requirementname)
          And a.employeeid in (select p.employeeid from ehr_compliancedb.employees p where a.employeeid = p.employeeid And p.enddate is null)
          And b.requirementname in  (select q.requirementname from ehr_compliancedb.Requirements q where q.requirementname = b.requirementname And q.dateDisabled is null )


          group by b.requirementname,a.employeeid

          union

          select a.requirementname,
                 a.employeeid,
                 null as unit,
                 null as category,
                 'None' as trackingflag,
                 (select h.email from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as  email,
                 (select h.lastname from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as lastname,
                 (select h.firstname from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as firstname,
                 (select h.majorudds from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as host,
                 (select h.supervisor from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as supervisor,
                 (select h.type from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as trainee_type,      ----- type trainee, or trainer
                 (select h.type from ehr_compliancedb.Requirements h where h.requirementname = a.requirementname) as requirement_type,      ----- type trainee, or trainer


                 (select count(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid  ) as timesCompleted,

                 (select k.expireperiod from ehr_compliancedb.Requirements k where k.requirementname = a.requirementname) as ExpiredPeriod,

                 ( select  (datediff(month,max(pq.date), tt.reviewdate) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                   having (COALESCE(tt.expireperiod,0)) > (datediff(month,max(pq.date), tt.reviewdate))  and (tt.reviewdate is not null)  ) as NewExpirePeriod,

                 (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid  ) as MostRecentDate,

                 (Select distinct string_agg(yy.comment, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid )
                                                                                                               And  yy.requirementname= a.requirementname and yy.employeeid= a.employeeid   ) as comment,

                 (Select distinct string_agg(yy.snooze_date, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid )
                                                                                                                   And  yy.requirementname= a.requirementname and yy.employeeid= a.employeeid   ) as snooze_date,

                 CAST(
                         CASE
                             WHEN (select max(st.date) from ehr_compliancedb.completiondates st where st.requirementname = a.requirementname and st.employeeid = a.employeeid ) IS NULL   then 0
                             WHEN ( select  (COALESCE(tt.expireperiod,0))  from  ehr_compliancedb.requirements tt where tt.requirementname = a.requirementname   group by tt.expireperiod  ) = 0 then Null


                             WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                    having (tt.reviewdate) >  ( cast(getdate() as date)  )) > 0 THEN

                                 ( select  (datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())) ) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                   having (tt.reviewdate) >  ( cast(getdate() as date)   )      )


                             ELSE ( select  (COALESCE(tt.expireperiod,0)) - ( datediff(month,max(pq.date), getdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod )

                             END  AS FLOAT)  AS MonthsUntilRenewal


          from  ehr_compliancedb.completiondates a
          where a.requirementname not in (select distinct h.requirementname from ehr_compliancedb.employeeperunit k, ehr_compliancedb.requirementspercategory h Where (k.unit = h.unit
              or k.category = h.category) And a.employeeid = k.employeeid )
            And a.requirementname not in (select distinct t.requirementname from ehr_compliancedb.employeerequirementexemptions t Where a.employeeid = t.employeeid
                                                                                                                                    And a.requirementname = t.requirementname)
            And a.employeeid in (select p.employeeid from ehr_compliancedb.employees p where a.employeeid = p.employeeid And p.enddate is null)
            And a.requirementname in  (select q.requirementname from ehr_compliancedb.Requirements q where q.requirementname = a.requirementname And q.dateDisabled is null )

          group by a.requirementname,a.employeeid

        union

        -- Additional requirements for employees that have not completed training, but is required
        select j.requirementname,
               j.employeeid,
               null as unit,
               null as category,
               string_agg(j.trackingflag,char(10)) as trackingflag,
              (select h.email from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as  email,
              (select h.lastname from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as lastname,
              (select h.firstname from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as firstname,
              (select h.majorudds from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as host,
              (select h.supervisor from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as supervisor,
              (select h.type from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as trainee_type,      ----- type trainee, or trainer
              (select h.type from ehr_compliancedb.Requirements h where h.requirementname = j.requirementname) as requirement_type,    ----- type trainee, or trainer
               0 as timesCompleted,
               (select k.expireperiod from ehr_compliancedb.Requirements k where k.requirementname = j.requirementname) as ExpiredPeriod,
               ( select  (datediff(month,max(pq.date), tt.reviewdate) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = j.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = j.employeeid group by tt.expireperiod, tt.reviewdate
                 having (COALESCE(tt.expireperiod,0)) > (datediff(month,max(pq.date), tt.reviewdate))  and (tt.reviewdate is not null)  ) as NewExpirePeriod,
               null as MostRecentDate,
               '' as comment,
               null as snooze_date,
               CAST(
                   CASE

                       WHEN (select max(st.date) from ehr_compliancedb.completiondates st where st.requirementname = j.requirementname and st.employeeid = j.employeeid ) IS NULL   then 0
                       WHEN ( select  (COALESCE(tt.expireperiod,0))  from  ehr_compliancedb.requirements tt where tt.requirementname = j.requirementname  group by tt.expireperiod  ) = 0 then Null


                       WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = j.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = j.employeeid group by tt.expireperiod, tt.reviewdate
                              having (tt.reviewdate) >  ( cast(getdate() as date)  )) > 0 THEN

                           ( select  (datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())) ) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   j.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = j.employeeid group by tt.expireperiod, tt.reviewdate
                             having (tt.reviewdate) >  ( cast(getdate() as date)   )      )




                       ELSE ( select  (COALESCE(tt.expireperiod,0)) - ( datediff(month,max(pq.date), getdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   j.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = j.employeeid group by tt.expireperiod )

                       END  AS FLOAT)  AS MonthsUntilRenewal



        from  ehr_compliancedb.RequirementsPerEmployee j
          Where j.employeeid in (select p.employeeid from ehr_compliancedb.employees p where j.employeeid = p.employeeid And p.enddate is null)
         And j.requirementname in  (select q.requirementname from ehr_compliancedb.Requirements q where q.requirementname = j.requirementname And q.dateDisabled is null )
          And  j.requirementname not in (select distinct h.requirementname from ehr_compliancedb.employeeperunit k, ehr_compliancedb.requirementspercategory h Where (k.unit = h.unit
              or k.category = h.category) And j.employeeid = k.employeeid )
            And j.requirementname not in (select distinct t.requirementname from ehr_compliancedb.employeerequirementexemptions t Where j.employeeid = t.employeeid  And j.requirementname = t.requirementname)
             And j.requirementname not in (select distinct k.requirementname from ehr_compliancedb.completiondates k Where k.employeeid = j.employeeid)

        group by j.requirementname,j.employeeid

        order by employeeid,requirementname, mostrecentcompleted_date desc


	       If @@Error <> 0
	                 GoTo Err_Proc




 RETURN 0


Err_Proc:

	RETURN 1


END

GO