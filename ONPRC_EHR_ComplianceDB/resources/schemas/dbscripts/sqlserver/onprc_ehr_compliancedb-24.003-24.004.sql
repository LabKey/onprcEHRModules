



-- Author:	R. Blasa
-- Created: 9-20-2024-2024
-- Description:	Stored procedure program to create a static data set for Compliance Procedure REcent Test .sq;


   CREATE TABLE onprc_ehr_compliancedb.ComplianceProcedureReport(
	[rowid] [int] IDENTITY(1,1) NOT NULL,
    [employeeid]  varchar(300) NULL,
	[requirementname] [varchar](4000) NULL,
	[unit] [varchar](500) NULL,
	[category] [varchar](500) NULL,
	[trackingflag] [varchar](100) NULL,
    [email] [varchar](500) NULL,
    [lastname] [varchar](500) NULL,
    [firstname] [varchar](500) NULL,
    [host] [varchar](500) NULL,
    [supervisor] [varchar](500) NULL,
    [trainee_type] [varchar](500) NULL,
	[times_completed] [smallint] NULL,
	[expired_period] [smallint] NULL,
	[new_expired_period] [smallint] NULL,
	[mostrecentcompleted_date] [smalldatetime] NULL,
	[comment] [varchar](4000) NULL,
	[snooze_date] [smalldatetime] NULL,
	[months_until_renewal] [decimal](4, 1) NULL,
	[requirement_name_type] [varchar](1000) NULL

 CONSTRAINT [PK_ComplianceOverdueSoonReport] PRIMARY KEY CLUSTERED
(
	[rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
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


DECLARE

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
                         times_completed,
                          expired_period,
                          new_expired_Perioed,
                          mostrecentcompleted_date,
                          comment,
                          snooze_date,
                          months_until_renewal,
                          requirement_name_type
                         )


        --------string_agg(CAST(BOOK.ID AS varchar(max)), ',')


        select b.requirementname,
               a.employeeid,
               string_agg(b.unit,char(10)) as unit,
               string_agg(a.category,char(10)) as category,
         	  (select top 1 h.trackingflag from ehr_compliancedb.requirementspercategory h where h.requirementname = b.requirementname) as trackingflag,
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
                 having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate))   and (tt.reviewdate is not null)  ) as NewExpirePeriod,

               (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid  ) as mostrecentcompleted_date,

               (Select string_agg(yy.comment, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= b.requirementname and yy.employeeid= a.employeeid   ) as comment,

               (Select yy.snooze_date from ehr_compliancedb.completiondates yy where yy.snooze_date in (select max(zz.snooze_date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= b.requirementname and yy.employeeid= a.employeeid   ) as snooze_date,

               CAST(
                       CASE

                           WHEN (select max(st.date) from ehr_compliancedb.completiondates st where st.requirementname = b.requirementname and st.employeeid = a.employeeid ) IS NULL   then 0
                           WHEN ( select  (tt.expireperiod)  from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod  ) = 0 then Null


                           WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                  having (tt.expireperiod) >  (datediff(month,max(pq.date), tt.reviewdate)  )) > 0 THEN

                               ( select  (datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                 having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate))  and (tt.reviewdate is not null)  )




                           ELSE ( select  (tt.expireperiod) - ( datediff(month,max(pq.date), getdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod )

                           END  AS DECIMAL)  AS MonthsUntilRenewal



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
               'No' as trackingflag,
              (select h.email from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as  email,
              (select h.lastname from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as lastname,
              (select h.firstname from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as firstname,
              (select h.majorudds from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as host,
              (select h.supervisor from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as supervisor,
              (select h.type from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as trainee_type,      ----- type trainee, or trainer
              (select h.type from ehr_compliancedb.Requirements h where h.requirementname = a.requirementname) as requirement_type,  ----- type trainee, or trainer


               (select count(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid  ) as timesCompleted,

               (select k.expireperiod from ehr_compliancedb.Requirements k where k.requirementname = a.requirementname) as ExpiredPeriod,

               ( select  (datediff(month,max(pq.date), tt.reviewdate) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                 having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate))  and (tt.reviewdate is not null)  ) as NewExpirePeriod,

               (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid  ) as MostRecentDate,

               (Select string_agg(yy.comment, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= a.requirementname and yy.employeeid= a.employeeid   ) as comment,

               (Select yy.snooze_date  from ehr_compliancedb.completiondates yy where yy.snooze_date in (select max(zz.snooze_date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= a.requirementname and yy.employeeid= a.employeeid   ) as snooze_date,

               CAST(
                       CASE
                           WHEN (select max(st.date) from ehr_compliancedb.completiondates st where st.requirementname = a.requirementname and st.employeeid = a.employeeid ) IS NULL   then 0
                           WHEN ( select  (tt.expireperiod)  from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod  ) = 0 then Null


                           WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                  having (tt.expireperiod) >  (datediff(month,max(pq.date), tt.reviewdate)  )) > 0 THEN

                               ( select  ( datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                 having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate)) and (tt.reviewdate is not null)  )


                           ELSE ( select  (tt.expireperiod) - ( datediff(month,max(pq.date), getdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod )

                           END  AS DECIMAL)  AS MonthsUntilRenewal


        from  ehr_compliancedb.completiondates a
        where a.requirementname not in (select distinct h.requirementname from ehr_compliancedb.employeeperunit k, ehr_compliancedb.requirementspercategory h Where (k.unit = h.unit
            or k.category = h.category) And a.employeeid = k.employeeid )
          And a.requirementname not in (select distinct t.requirementname from ehr_compliancedb.employeerequirementexemptions t Where a.employeeid = t.employeeid
                                                                                                                                  And a.requirementname = t.requirementname)
          And a.employeeid in (select p.employeeid from ehr_compliancedb.employees p where a.employeeid = p.employeeid And p.enddate is null)
          And a.requirementname in  (select q.requirementname from ehr_compliancedb.Requirements q where q.requirementname = a.requirementname And q.dateDisabled is null )

        group by a.requirementname,a.employeeid

        UNION

        -- Additional requirements for employees that have not completed training, but is required
        select j.requirementname,
               j.employeeid,
               null as unit,
               null as category,
               'Yes' as trackingflag,
              (select h.email from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as  email,
              (select h.lastname from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as lastname,
              (select h.firstname from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as firstname,
              (select h.majorudds from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as host,
              (select h.supervisor from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as supervisor,
              (select h.type from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as trainee_type,      ----- type trainee, or trainer
              (select h.type from ehr_compliancedb.Requirements h where h.requirementname = j.requirementname) as requirement_type,    ----- type trainee, or trainer
               null as timesCompleted,
               null as ExpiredPeriod,
               null as NewExpirePeriod,
               null as MostRecentDate,
               '' as comment,
               null as snooze_date,
               null AS MonthsUntilRenewal



        from  ehr_compliancedb.RequirementsPerEmployee j
        Where j.requirementname not in (select z.requirementname from ehr_compliancedb.completiondates z where z.requirementname = j.requirementname
          and z.employeeid = j.employeeid and z.date is not null)
          And j.employeeid in (select p.employeeid from ehr_compliancedb.employees p where j.employeeid = p.employeeid And p.enddate is null)
         And j.requirementname in  (select q.requirementname from ehr_compliancedb.Requirements q where q.requirementname = j.requirementname And q.dateDisabled is null )

        group by j.requirementname,j.employeeid

        order by employeeid,requirementname, mostrecentcompleted_date desc


	       If @@Error <> 0
	                 GoTo Err_Proc




 RETURN 0


Err_Proc:
                    -------Error Generated, Transfer process stopped
	RETURN 1


END

GO