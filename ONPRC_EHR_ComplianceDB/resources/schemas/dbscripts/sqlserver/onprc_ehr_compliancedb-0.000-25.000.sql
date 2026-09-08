CREATE SCHEMA onprc_ehr_compliancedb;
GO

CREATE TABLE onprc_ehr_compliancedb.SciShield_Data
(
    RowId INT IDENTITY(1,1) NOT NULL,
    employeeId nvarchar(255) not null,
    requirementname nvarchar(255) null,
    Date datetime null,
    Container ENTITYID NOT NULL,
    comment nvarchar(2000) null,
    CreatedBy USERID,
    Created datetime,
    ModifiedBy USERID,
    Modified datetime,
    processed int NULL

    CONSTRAINT PK_ScieShield_Data PRIMARY KEY (RowId),
    CONSTRAINT FK_ONPRC_EHR_COMPLIANCE_SCISHIELD_DATA_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
CREATE INDEX IX_ONPRC_EHR_COMPLIANCEDB_SCISHIELD_DATA_CONTAINER ON onprc_ehr_compliancedb.SciShield_Data (Container);

CREATE TABLE onprc_ehr_compliancedb.SciShield_Reference_Data
(
    rowId int identity(1,1),
    label nvarchar(250) NULL,
    value nvarchar(255) NOT NULL ,
    columnName nvarchar(255)  NOT NULL,
    sort_order integer  null,
    endDate  datetime  NULL,
    Container ENTITYID NOT NULL,
    CreatedBy USERID,
    Created datetime,
    ModifiedBy USERID,
    Modified datetime,

    CONSTRAINT pk_SciShield_reference PRIMARY KEY (value),
    CONSTRAINT FK_ONPRC_EHR_COMPLIANCE_REFERENCE_DATA_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
CREATE INDEX IX_ONPRC_EHR_COMPLIANCEDB_SCISHIELD_REFERENCE_DATA_CONTAINER ON onprc_ehr_compliancedb.SciShield_Reference_Data (Container);

GO

/* 24.xxx SQL scripts */

-- Author:	R. Blasa
-- Created: 2-10-2024
-- Description:	Stored procedure program process SciShield INitial Data


CREATE TABLE [onprc_ehr_compliancedb].[SciShieldTemp] (
    [searchID] [int] IDENTITY(100,1) NOT NULL,
    [employeeid] [varchar](500) NULL,
    [requirementname] [varchar](3000) NULL,
    [completeddate] [smalldatetime] NULL,
    [comment] [varchar](300) NULL,
    [createddate] [smalldatetime] NULL,
    [rowid] [int] NULL
    ) ON [PRIMARY]
    GO

CREATE TABLE [onprc_ehr_compliancedb].[SciShieldMasterTemp](
    [searchID] [int] IDENTITY(100,1) NOT NULL,
    [employeeid] [varchar](500) NULL,
    [requirementname] [varchar](3000) NULL,
    [completeddate] [smalldatetime] NULL,
    [comment] [varchar](300) NULL,
    [createddate] [smalldatetime] NULL,
    [rowid] [int] NULL
    ) ON [PRIMARY]
    GO



-- Author:	R. Blasa
-- Created: 2-10-2024

/*
**
** 	Created by
**      Blasa  		1-25-2024               Import process from ScieShield To Prime Compliance Module
**
**                                                 Processed codes:    Null    ---Not Processed
**                                                                          1 ------  Successfully posted
**                                                                        2 ---------  invalid Employeeid
**                                                                        3  ---------  Undefined Requirement Name
**                                                                           4---------     Already exists Compliance module
**
**
**
*/

CREATE Procedure onprc_ehr_compliancedb.[p_SciShieldToPrimeProcess]


AS


DECLARE
                          @SearchKey               Int,
			              @TempsearchKey	       Int,
			              @requirementnameFinal    varchar(2000),
                          @requirementnanme        varchar(2000),
                          @employeeid              varchar(500),
                          @Completiondate          smalldatetime,
                          @SciShieldID              int





BEGIN

    ---- Reset temp table

         Delete onprc_ehr_compliancedb.SciShieldTemp


	       If @@Error <> 0
	           GoTo Err_Proc


If exists(Select * from  onprc_ehr_compliancedb.SciShield_Data  where processed is null)
BEGIN

   Insert into onprc_ehr_compliancedb.SciShieldTemp
     (
    employeeid,
    requirementname,
    completeddate,
    createddate,
    rowid
     )


   select
    employeeid,              -------employeeid
    requirementname,          ----requirement name
    date,                     ----completed Date
    getdate(),                 --- created date
    rowid                     --- SciShield unique id


      from  onprc_ehr_compliancedb.SciShield_Data
          where processed is null

          order by employeeid, requirementname, date desc

                If @@Error <> 0
                     GoTo Err_Proc

 END

ELSE             ------ No new entries exit
  BEGIN

    GOTO No_Records

  END

                        --- Initialize Varaibles

                       Set @TempsearchKey = 0
                       Set @SearchKey = 0



                    --- Start processing input records from SciShield


          Select top 1 @searchkey = searchID from onprc_ehr_compliancedb.SciShieldTemp
                  order by searchID




While @TempSearchKey < @SearchKey
 BEGIN
			                  Set  @requirementnameFinal = ''
                              Set @requirementnanme = ''
                              Set @employeeid = ''
                              Set @Completiondate = Null
                              Set @SciShieldID = Null


         Select @employeeid =rtrim(ltrim(lower(employeeid))),  @requirementnanme = requirementname, @completiondate = completeddate, @SciShieldID = rowid
             from onprc_ehr_compliancedb.SciShieldTemp Where  searchID = @Searchkey

                              ---Validate requirementname
  IF exists (Select * from onprc_ehr_compliancedb.SciShield_Reference_Data where label =  @requirementnanme And columnname = 'requirementname' )
   BEGIN

       Select @requirementnameFinal = value from onprc_ehr_compliancedb.SciShield_Reference_Data where label = @requirementnanme And columnname = 'requirementname'
   END
  ELSE IF exists (Select * from ehr_compliancedb.requirements where requirementname =  @requirementnanme)
   BEGIN
       Select @requirementnameFinal = requirementname from ehr_compliancedb.requirements where requirementname = @requirementnanme
   END

   ELSE
    BEGIN
       Update ss
           Set ss.processed = 3

    From onprc_ehr_compliancedb.SciShield_Data ss  Where ss.rowid = @SciShieldID

        If @@Error <> 0
           GoTo Err_Proc

        GOTO Next_Record
    END

                    ----validate if the record already exists

 IF exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    And date = @completiondate)
  BEGIN
      Update ss
       Set ss.processed = 4

    From onprc_ehr_compliancedb.SciShield_Data ss  Where ss.rowid = @SciShieldID

         If @@Error <> 0
              GoTo Err_Proc

            GOTO Next_Record
    END


                                ----validate if the employeeid is defined

 IF not exists( Select * from ehr_compliancedb.employees Where employeeid = @employeeid And enddate is null)
  BEGIN

     Update ss
        Set ss.processed = 2

    From onprc_ehr_compliancedb.SciShield_Data ss  Where ss.rowid = @SciShieldID


            If @@Error <> 0
                  GoTo Err_Proc

    GOTO Next_Record



  END  ----


                 ---- IF all previous version were validated proceed with the record insert


   IF not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    And date = @completiondate)

    BEGIN
      Insert into ehr_compliancedb.completiondates
         (employeeid,
          requirementname,
           date,
           trainer,
           container,
           created,
           createdby,
           modified,
           modifiedby

         )
        values(
          @employeeid,
          @requirementnameFinal,
          @completiondate,
          'ONLINE TRAINING',
          'CD170458-C55F-102F-9907-5107380A54BE',
          getdate(),
          2595,
          getdate(),
          2595
      )
                       If @@Error <> 0
	                                   GoTo Err_Proc




---------- Set successful entry flag

      Update ss
          Set ss.processed = 1

    From onprc_ehr_compliancedb.SciShield_Data ss  Where ss.rowid = @SciShieldID


    If @@Error <> 0
    GoTo Err_Proc

END  ----




Next_Record:



	                      Set @TempSearchkey = @SearchKey


       Select Top 1 @Searchkey = searchID  from onprc_ehr_compliancedb.SciShieldTemp
                          Where searchID > @TempSearchkey
             Order by searchID



END  ---(While)



     ---- Create a master records of the last most recent entries
    If exists (Select * from onprc_ehr_compliancedb.SciShieldTemp)
    BEGiN
       Insert into onprc_ehr_compliancedb.SciShieldMasterTemp
       select
         employeeid,
         requirementname,
         completeddate,
         comment,
         createddate,
         rowid


         from onprc_ehr_compliancedb.SciShieldTemp


         If @@Error <> 0
	                GoTo Err_Proc
END

No_Records:

 RETURN 0


Err_Proc:
                    -------Error Generated, Transfer process stopped
	RETURN 1


END

GO

CREATE INDEX IX_completiondates_trainer ON ehr_compliancedb.completiondates(trainer);
GO

-- Author:	R. Blasa
-- Created: 9-16-2024

/*
**
** 	Created by
**      Blasa  		9-16-2024               Storedprocedure to update Compliance Access contaimer values
**
**
**
*/

CREATE Procedure onprc_ehr_compliancedb.[p_ComplianceAccesscontainerUpdate]


AS



BEGIN

          ------ Update container value and include as part of the main Compliance module

If exists(Select * from  ehr_Compliancedb.CompletionDates ss where ss.container =  '47F00C3F-5691-103D-8866-41AD310B2640' )
BEGIN

  Update ss
    set ss.container =   'CD170458-C55F-102F-9907-5107380A54BE'    ----Compliance folder on Prime Production

   from  ehr_Compliancedb.CompletionDates ss
    Where ss.container = 'F1C05E2D-618D-103D-ABC9-9814909BFFCD'    ---Compliance Access folder on Prime Production

                If @@Error <> 0
                     GoTo Err_Proc

 END

ELSE             ------ No new entries exit
  BEGIN

    GOTO No_Records

  END




No_Records:

 RETURN 0


Err_Proc:
                    -------Error Generated, Transfer process stopped
	RETURN 1


END

GO

EXEC core.fn_dropifexists 'p_ComplianceAccesscontainerUpdate', 'onprc_ehr_compliancedb', 'PROCEDURE';
GO

-- Author:	R. Blasa
-- Created: 10-2-2024

/*
**
** 	Created by
**      Blasa  		9-16-2024               Storedprocedure to update Compliance Access contaimer values.
**                  10-2-2024               Corrected Container values.
**
**
**
*/

CREATE Procedure onprc_ehr_compliancedb.p_ComplianceAccesscontainerUpdate


AS



BEGIN

          ------ Update container value and include as part of the main Compliance module

If exists(Select * from  ehr_Compliancedb.CompletionDates ss where ss.container =  'F1C05E2D-618D-103D-ABC9-9814909BFFCD' )
BEGIN

  Update ss
    set ss.container =   'CD170458-C55F-102F-9907-5107380A54BE'    ----Compliance folder on Prime Production

   from  ehr_Compliancedb.CompletionDates ss
    Where ss.container = 'F1C05E2D-618D-103D-ABC9-9814909BFFCD'    ---Compliance Access folder on Prime Production

                If @@Error <> 0
                     GoTo Err_Proc

 END

ELSE             ------ No new entries exit
  BEGIN

    GOTO No_Records

  END




No_Records:

 RETURN 0


Err_Proc:
                    -------Error Generated, Transfer process stopped
	RETURN 1


END

GO

EXEC core.fn_dropifexists 'p_ComplianceAccesscontainerUpdate', 'onprc_ehr_compliancedb', 'PROCEDURE';
GO

-- Author:	R. Blasa
-- Created: 12-10-2024

/*
**
** 	Created by
**      Blasa  		12-10-2024               Storedprocedure to update string name "ARRS" to "DCM"
**
**
**
**
*/

CREATE Procedure onprc_ehr_compliancedb.p_ComplianceTranslatestringUpdate


AS



BEGIN

          ------ Update container value and include as part of the main Compliance module

If exists(select * from ehr_compliancedb.EmployeePerUnit         ------> count= 496
          where unit like '%arrs%'
 )
BEGIN

      Update  ehr_compliancedb.EmployeePerUnit
          set unit = replace(unit,'arrs', 'DCM')



                If @@Error <> 0
                     GoTo Err_Proc

 END


 If exists(select * from ehr_compliancedb.EmployeePerUnit         ------> count= 496
           where  category like '%arrs%'
  )
 BEGIN

       Update  ehr_compliancedb.EmployeePerUnit
           set category = replace(category,'arrs', 'DCM')



                 If @@Error <> 0
                      GoTo Err_Proc

  END



 If exists(select * from ehr_compliancedb.Employees
               where majorudds  like '%arrs%'
  )
 BEGIN

       Update  ehr_compliancedb.Employees
           set majorudds   = replace(majorudds,'arrs', 'DCM')



                 If @@Error <> 0
                      GoTo Err_Proc

  END



 If exists(select * from ehr_compliancedb.Employees
               where unit  like '%arrs%'
  )
 BEGIN

       Update  ehr_compliancedb.Employees
           set unit = replace(unit,'arrs', 'DCM')

                 If @@Error <> 0
                      GoTo Err_Proc

  END



 If exists(select * from ehr_compliancedb.Employees
               where  category  like '%arrs%'
  )
 BEGIN

       Update  ehr_compliancedb.Employees
           set category = replace(category,'arrs', 'DCM')

                 If @@Error <> 0
                      GoTo Err_Proc

  END



 If exists(select * from ehr_compliancedb.requirements
               where requirementname  like '%arrs%'
  )
 BEGIN

       Update  ehr_compliancedb.requirements
           set requirementname = replace(requirementname,'arrs', 'DCM')


                 If @@Error <> 0
                      GoTo Err_Proc

  END



 If exists(select * from ehr_compliancedb.EmployeeRequirementExemptions
               where requirementname  like '%arrs%'
  )
 BEGIN

       Update  ehr_compliancedb.EmployeeRequirementExemptions
           set requirementname = replace(requirementname,'arrs', 'DCM')


                 If @@Error <> 0
                      GoTo Err_Proc

  END




   If exists(select * from ehr_compliancedb.unit_names
             where unit  like '%arrs%'
    )
   BEGIN

         Update  ehr_compliancedb.unit_names
             set unit = replace(unit,'arrs', 'DCM')



                   If @@Error <> 0
                        GoTo Err_Proc

    END


   If exists(select * from ehr_compliancedb.RequirementsPerCategory
                 where RequirementName  like '%arrs%'
    )
   BEGIN

         Update  ehr_compliancedb.RequirementsPerCategory
             set requirementname = replace(requirementname,'arrs', 'DCM')



                   If @@Error <> 0
                        GoTo Err_Proc

    END


 If exists(select * from ehr_compliancedb.RequirementsPerCategory
           where category  like '%arrs%'
    )
   BEGIN

         Update  ehr_compliancedb.RequirementsPerCategory
             set category = replace(category,'arrs', 'DCM')

                   If @@Error <> 0
                        GoTo Err_Proc

    END


   If exists(select * from ehr_compliancedb.RequirementsPerCategory
             where unit  like '%arrs%'
      )
     BEGIN

        Update  ehr_compliancedb.RequirementsPerCategory
            set unit = replace(unit,'arrs', 'DCM')


                     If @@Error <> 0
                          GoTo Err_Proc

      END

  If exists(select * from ehr_compliancedb.completiondates
                           where  requirementname  like '%arrs%'
     )
    BEGIN

                 Update  ehr_compliancedb.completiondates
                     set requirementname = replace(requirementname,'arrs', 'DCM')


                    If @@Error <> 0
                         GoTo Err_Proc

     END

  If exists(select * from ehr_compliancedb.EmployeeCategory
            where categoryname  like '%arrs%'
     )
    BEGIN

          Update   ehr_compliancedb.EmployeeCategory
                 set categoryname  = replace(categoryname ,'arrs', 'DCM')


                    If @@Error <> 0
                         GoTo Err_Proc

     END








No_Records:

 RETURN 0


Err_Proc:
                    --
	RETURN 1


END

GO

-- Author:	R. Blasa
-- Created: 9-20-2024-2024
-- Description:	Stored procedure program to create a static data set for Compliance Procedure Recent Test .sql


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
	[months_until_renewal] [Float] NULL,
	[requirement_name_type] [varchar](1000) NULL

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

               (Select distinct string_agg(yy.comment, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= b.requirementname and yy.employeeid= a.employeeid   ) as comment,

               (Select distinct string_agg(yy.snooze_date, char(10)) from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= b.requirementname and yy.employeeid= a.employeeid   ) as snooze_date,

               CAST(
                       CASE

                           WHEN (select max(st.date) from ehr_compliancedb.completiondates st where st.requirementname = b.requirementname and st.employeeid = a.employeeid ) IS NULL   then 0
                           WHEN ( select  (tt.expireperiod)  from  ehr_compliancedb.requirements tt where tt.requirementname = b.requirementname   group by tt.expireperiod  ) = 0 then Null


                           WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                  having (tt.expireperiod) >  ( datediff(month,max(pq.date), tt.reviewdate)        )) > 0 THEN

                               ( select  (datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())   ) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                 having (tt.expireperiod) > ( datediff(month,max(pq.date), tt.reviewdate)    )      )




                           ELSE ( select  (tt.expireperiod) - ( datediff(month,max(pq.date), getdate()) )  from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod )

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

               (Select distinct string_agg(yy.comment, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= a.requirementname and yy.employeeid= a.employeeid   ) as comment,

               (Select distinct string_agg(yy.snooze_date, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= a.requirementname and yy.employeeid= a.employeeid   ) as snooze_date,

               CAST(
                       CASE
                           WHEN (select max(st.date) from ehr_compliancedb.completiondates st where st.requirementname = a.requirementname and st.employeeid = a.employeeid ) IS NULL   then 0
                           WHEN ( select  (tt.expireperiod)  from  ehr_compliancedb.requirements tt where tt.requirementname = a.requirementname  group by tt.expireperiod  ) = 0 then Null


                           WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                  having (tt.expireperiod) >  ( datediff(month,max(pq.date), tt.reviewdate)      )) > 0 THEN

                               ( select  ( datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                 having (tt.expireperiod) > ( datediff(month,max(pq.date), tt.reviewdate)     )   )


                           ELSE ( select  (tt.expireperiod) - ( datediff(month,max(pq.date), getdate()) ) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod )

                           END  AS Float)  AS MonthsUntilRenewal


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
              (select h.type from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as trainee_type,      ----- type trainee, or trainer
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

	RETURN 1


END

GO

-- Author:	R. Blasa
-- Created: 9-20-2024-2024
-- Description:	Stored procedure program to create a static data set for Compliance Recent Test .sql


   CREATE TABLE onprc_ehr_compliancedb.ComplianceRecentReport(
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
	[months_until_renewal] [FLOAT] NULL,
	[requirement_name_type] [varchar](1000) NULL

 ) ON [PRIMARY]
    GO


-- Author:	R. Blasa
-- Created: 9-20-2024

/*
**
** 	Created by
**      Blasa  		9-20-2024     Created a storedprocedure to create a static set of data from
**                                 the ComplianceRecentTest.sql query
**
**
**
*/

CREATE Procedure onprc_ehr_compliancedb.p_ComplianceRecentOverDueSoon_Process


AS



              ----- Reset Reporting table
              Delete onprc_ehr_compliancedb.ComplianceRecentReport

	                      If @@Error <> 0
	                                GoTo Err_Proc



BEGIN

          Insert into onprc_ehr_compliancedb.ComplianceRecentReport
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
         	  (select top 1 h.trackingflag from ehr_compliancedb.requirementspercategory h where h.requirementname = b.requirementname) as trackingflag,
              (select h.email from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as  email,
              (select h.lastname from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as lastname,
              (select h.firstname from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as firstname,
              (select h.majorudds from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as host,
              (select h.supervisor from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as supervisor,
              (select h.type from ehr_compliancedb.employees h where h.employeeid = a.employeeid) as trainee_type,      ----- type trainee, or trainer
              (select h.type from ehr_compliancedb.Requirements h where h.requirementname = b.requirementname) as requirement_type,  ----- type trainee, or trainer


               (select count(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid  ) as times_Completed,

               (select k.expireperiod from ehr_compliancedb.Requirements k where k.requirementname = b.requirementname) as ExpiredPeriod,

               ( select  (datediff(month,max(pq.date), tt.reviewdate) ) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                 having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate))   and (tt.reviewdate is not null)  ) as NewExpirePeriod,

               (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid  ) as mostrecentcompleted_date,

               (Select distinct string_agg(yy.comment, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= b.requirementname and yy.employeeid= a.employeeid   ) as comment,

               (Select distinct string_agg(yy.snooze_date, char(10)) from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= b.requirementname and yy.employeeid= a.employeeid   ) as snooze_date,

               CAST(
                       CASE

                           WHEN (select max(st.date) from ehr_compliancedb.completiondates st where st.requirementname = b.requirementname and st.employeeid = a.employeeid ) IS NULL   then 0
                           WHEN ( select  (tt.expireperiod)  from  ehr_compliancedb.requirements tt where tt.requirementname = b.requirementname  group by tt.expireperiod  ) = 0 then Null


                           WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                  having (tt.expireperiod) >  ( datediff(month,max(pq.date), tt.reviewdate)  ) ) > 0 THEN

                               ( select  (datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())) ) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                 having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate)  )   )




                           ELSE ( select  (tt.expireperiod) - ( datediff(month,max(pq.date), getdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod )

                           END  AS FLOAT)  AS MonthsUntilRenewal



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
              (select h.type from ehr_compliancedb.Requirements h where h.requirementname = a.requirementname) as requirement_type,      ----- type trainee, or trainer


               (select count(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid  ) as timesCompleted,

               (select k.expireperiod from ehr_compliancedb.Requirements k where k.requirementname = a.requirementname) as ExpiredPeriod,

               ( select  (datediff(month,max(pq.date), tt.reviewdate) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                 having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate))  and (tt.reviewdate is not null)  ) as NewExpirePeriod,

               (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid  ) as MostRecentDate,

               (Select distinct string_agg(yy.comment, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= a.requirementname and yy.employeeid= a.employeeid   ) as comment,

               (Select distinct string_agg(yy.snooze_date, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= a.requirementname and yy.employeeid= a.employeeid   ) as snooze_date,

               CAST(
                       CASE
                           WHEN (select max(st.date) from ehr_compliancedb.completiondates st where st.requirementname = a.requirementname and st.employeeid = a.employeeid ) IS NULL   then 0
                           WHEN ( select  (tt.expireperiod)  from  ehr_compliancedb.requirements tt where tt.requirementname = a.requirementname   group by tt.expireperiod  ) = 0 then Null


                           WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                  having (tt.expireperiod) >  (datediff(month,max(pq.date), tt.reviewdate)  )) > 0 THEN

                               ( select  (datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())) ) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                 having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate) )   )


                           ELSE ( select  (tt.expireperiod) - ( datediff(month,max(pq.date), getdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod )

                           END  AS FLOAT)  AS MonthsUntilRenewal


        from  ehr_compliancedb.completiondates a
        where a.requirementname not in (select distinct h.requirementname from ehr_compliancedb.employeeperunit k, ehr_compliancedb.requirementspercategory h Where (k.unit = h.unit
            or k.category = h.category) And a.employeeid = k.employeeid )
          And a.requirementname not in (select distinct t.requirementname from ehr_compliancedb.employeerequirementexemptions t Where a.employeeid = t.employeeid
                                                                                                                                  And a.requirementname = t.requirementname)
          And a.employeeid in (select p.employeeid from ehr_compliancedb.employees p where a.employeeid = p.employeeid And p.enddate is null)
          And a.requirementname in  (select q.requirementname from ehr_compliancedb.Requirements q where q.requirementname = a.requirementname And q.dateDisabled is null )

        group by a.requirementname,a.employeeid

        UNION

        --- Training that was completed by as an employee training exemptions, and at least completed one, or more times

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
                  (select h.type from ehr_compliancedb.Requirements h where h.requirementname = a.requirementname) as requirement_type,      ----- type trainee, or trainer


                   (select count(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid  ) as timesCompleted,

                   (select k.expireperiod from ehr_compliancedb.Requirements k where k.requirementname = a.requirementname) as ExpiredPeriod,

                   ( select  (datediff(month,max(pq.date), tt.reviewdate) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                     having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate))  and (tt.reviewdate is not null)  ) as NewExpirePeriod,

                   (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid  ) as MostRecentDate,

                   (Select distinct string_agg(yy.comment, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid )
                                                                                                 And  yy.requirementname= a.requirementname and yy.employeeid= a.employeeid   ) as comment,

                   (Select distinct string_agg(yy.snooze_date, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid )
                                                                                                 And  yy.requirementname= a.requirementname and yy.employeeid= a.employeeid   ) as snooze_date,

                   CAST(
                           CASE
                               WHEN (select max(st.date) from ehr_compliancedb.completiondates st where st.requirementname = a.requirementname and st.employeeid = a.employeeid ) IS NULL   then 0
                               WHEN ( select  (tt.expireperiod)  from  ehr_compliancedb.requirements tt where tt.requirementname = a.requirementname   group by tt.expireperiod  ) = 0 then Null


                               WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                      having (tt.expireperiod) >  (datediff(month,max(pq.date), tt.reviewdate) )) > 0 THEN

                                   ( select  ( datediff(month,max(pq.date), tt.reviewdate) - (datediff(month,max(pq.date), getdate())) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                     having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate))   )


                               ELSE ( select  (tt.expireperiod) - ( datediff(month,max(pq.date), getdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod )

                               END  AS DECIMAL)  AS MonthsUntilRenewal


        from  ehr_compliancedb.employeerequirementexemptions a
            Where a.requirementname in (select z.requirementname from ehr_compliancedb.completiondates z where z.requirementname = a.requirementname
                                                    and z.employeeid = a.employeeid and z.date is not null)
              And a.employeeid in (select p.employeeid from ehr_compliancedb.employees p where a.employeeid = p.employeeid And p.enddate is null)
              And a.requirementname in  (select q.requirementname from ehr_compliancedb.Requirements q where q.requirementname = a.requirementname And q.dateDisabled is null )

        group by a.requirementname,a.employeeid

        UNION

        --- Additional requirements for employees that have not completed training, but is required

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
              (select h.type from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as trainee_type,      ----- type trainee, or trainer
              (select h.type from ehr_compliancedb.Requirements h where h.requirementname = j.requirementname) as requirement_type,      ----- type trainee, or trainer

              (select count(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= j.requirementname and zz.employeeid= j.employeeid  ) as timesCompleted,

                                (select k.expireperiod from ehr_compliancedb.Requirements k where k.requirementname = j.requirementname) as ExpiredPeriod,

                                ( select  (datediff(month,max(pq.date), tt.reviewdate) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   j.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = j.employeeid group by tt.expireperiod, tt.reviewdate
                                  having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate))  and (tt.reviewdate is not null)  ) as NewExpirePeriod,

                                (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= j.requirementname and zz.employeeid= j.employeeid  ) as MostRecentDate,

                                (Select distinct string_agg(yy.comment, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= j.requirementname and zz.employeeid= j.employeeid )
                                                                                                              And  yy.requirementname= j.requirementname and yy.employeeid= j.employeeid   ) as comment,

                                (Select distinct string_agg(yy.snooze_date, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= j.requirementname and zz.employeeid= j.employeeid )
                                                                                                              And  yy.requirementname= j.requirementname and yy.employeeid= j.employeeid   ) as snooze_date,

                                CAST(
                                        CASE
                                            WHEN (select max(st.date) from ehr_compliancedb.completiondates st where st.requirementname = j.requirementname and st.employeeid = j.employeeid ) IS NULL   then 0
                                            WHEN ( select  (tt.expireperiod)  from  ehr_compliancedb.requirements tt where tt.requirementname = j.requirementname   group by tt.expireperiod  ) = 0 then Null


                                            WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = j.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = j.employeeid group by tt.expireperiod, tt.reviewdate
                                                   having (tt.expireperiod) >  (datediff(month,max(pq.date), tt.reviewdate) )) > 0 THEN

                                                ( select  ( datediff(month,max(pq.date), tt.reviewdate) - (datediff(month,max(pq.date), getdate())) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   j.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = j.employeeid group by tt.expireperiod, tt.reviewdate
                                                  having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate))   )


                                            ELSE ( select  (tt.expireperiod) - ( datediff(month,max(pq.date), getdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   j.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = j.employeeid group by tt.expireperiod )

                                            END  AS DECIMAL)  AS MonthsUntilRenewal





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

	RETURN 1


END

GO

EXEC core.fn_dropifexists 'p_ComplianceRecentOverDueSoon_Process', 'onprc_ehr_compliancedb', 'PROCEDURE';
GO

-- Author:	R. Blasa
-- Created: 9-20-2024

/*
**
** 	Created by
**      Blasa  		9-20-2024     Created a storedprocedure to create a static set of data from
**                                 the ComplianceRecentTest.sql query
**
**
**
*/

CREATE Procedure onprc_ehr_compliancedb.p_ComplianceRecentOverDueSoon_Process


AS



              ----- Reset Reporting table
              Delete onprc_ehr_compliancedb.ComplianceRecentReport

	                      If @@Error <> 0
	                                GoTo Err_Proc



BEGIN

          Insert into onprc_ehr_compliancedb.ComplianceRecentReport
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
              (select h.type from ehr_compliancedb.Requirements h where h.requirementname = b.requirementname) as requirement_type,  ----- type trainee, or trainer


               (select count(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid  ) as times_Completed,

               (select k.expireperiod from ehr_compliancedb.Requirements k where k.requirementname = b.requirementname) as ExpiredPeriod,

               ( select  (datediff(month,max(pq.date), tt.reviewdate) ) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                 having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate))   and (tt.reviewdate is not null)  ) as NewExpirePeriod,

               (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid  ) as mostrecentcompleted_date,

               (Select distinct string_agg(yy.comment, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= b.requirementname and yy.employeeid= a.employeeid   ) as comment,

               (Select distinct string_agg(yy.snooze_date, char(10)) from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= b.requirementname and yy.employeeid= a.employeeid   ) as snooze_date,

               CAST(
                       CASE

                           WHEN (select max(st.date) from ehr_compliancedb.completiondates st where st.requirementname = b.requirementname and st.employeeid = a.employeeid ) IS NULL   then 0
                           WHEN ( select  (tt.expireperiod)  from  ehr_compliancedb.requirements tt where tt.requirementname = b.requirementname  group by tt.expireperiod  ) = 0 then Null


                           WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                  having (tt.expireperiod) >  ( datediff(month,max(pq.date), tt.reviewdate)  ) ) > 0 THEN

                               ( select  (datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())) ) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                 having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate)  )   )




                           ELSE ( select  (tt.expireperiod) - ( datediff(month,max(pq.date), getdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod )

                           END  AS FLOAT)  AS MonthsUntilRenewal



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
                 having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate))  and (tt.reviewdate is not null)  ) as NewExpirePeriod,

               (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid  ) as MostRecentDate,

               (Select distinct string_agg(yy.comment, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= a.requirementname and yy.employeeid= a.employeeid   ) as comment,

               (Select distinct string_agg(yy.snooze_date, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= a.requirementname and yy.employeeid= a.employeeid   ) as snooze_date,

               CAST(
                       CASE
                           WHEN (select max(st.date) from ehr_compliancedb.completiondates st where st.requirementname = a.requirementname and st.employeeid = a.employeeid ) IS NULL   then 0
                           WHEN ( select  (tt.expireperiod)  from  ehr_compliancedb.requirements tt where tt.requirementname = a.requirementname   group by tt.expireperiod  ) = 0 then Null


                           WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                  having (tt.expireperiod) >  (datediff(month,max(pq.date), tt.reviewdate)  )) > 0 THEN

                               ( select  (datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())) ) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                 having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate) )   )


                           ELSE ( select  (tt.expireperiod) - ( datediff(month,max(pq.date), getdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod )

                           END  AS FLOAT)  AS MonthsUntilRenewal


        from  ehr_compliancedb.completiondates a
        where a.requirementname not in (select distinct h.requirementname from ehr_compliancedb.employeeperunit k, ehr_compliancedb.requirementspercategory h Where (k.unit = h.unit
            or k.category = h.category) And a.employeeid = k.employeeid )
          And a.requirementname not in (select distinct t.requirementname from ehr_compliancedb.employeerequirementexemptions t Where a.employeeid = t.employeeid
                                                                                                                                  And a.requirementname = t.requirementname)
          And a.employeeid in (select p.employeeid from ehr_compliancedb.employees p where a.employeeid = p.employeeid And p.enddate is null)
          And a.requirementname in  (select q.requirementname from ehr_compliancedb.Requirements q where q.requirementname = a.requirementname And q.dateDisabled is null )

        group by a.requirementname,a.employeeid

        UNION

        --- Training that was completed by as an employee training exemptions, and at least completed one, or more times

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
                  (select h.type from ehr_compliancedb.Requirements h where h.requirementname = a.requirementname) as requirement_type,      ----- type trainee, or trainer


                   (select count(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid  ) as timesCompleted,

                   (select k.expireperiod from ehr_compliancedb.Requirements k where k.requirementname = a.requirementname) as ExpiredPeriod,

                   ( select  (datediff(month,max(pq.date), tt.reviewdate) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                     having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate))  and (tt.reviewdate is not null)  ) as NewExpirePeriod,

                   (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid  ) as MostRecentDate,

                   (Select distinct string_agg(yy.comment, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid )
                                                                                                 And  yy.requirementname= a.requirementname and yy.employeeid= a.employeeid   ) as comment,

                   (Select distinct string_agg(yy.snooze_date, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid )
                                                                                                 And  yy.requirementname= a.requirementname and yy.employeeid= a.employeeid   ) as snooze_date,

                   CAST(
                           CASE
                               WHEN (select max(st.date) from ehr_compliancedb.completiondates st where st.requirementname = a.requirementname and st.employeeid = a.employeeid ) IS NULL   then 0
                               WHEN ( select  (tt.expireperiod)  from  ehr_compliancedb.requirements tt where tt.requirementname = a.requirementname   group by tt.expireperiod  ) = 0 then Null


                               WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                      having (tt.expireperiod) >  (datediff(month,max(pq.date), tt.reviewdate) )) > 0 THEN

                                   ( select  ( datediff(month,max(pq.date), tt.reviewdate) - (datediff(month,max(pq.date), getdate())) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                     having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate))   )


                               ELSE ( select  (tt.expireperiod) - ( datediff(month,max(pq.date), getdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod )

                               END  AS DECIMAL)  AS MonthsUntilRenewal


        from  ehr_compliancedb.employeerequirementexemptions a
              Where a.employeeid in (select p.employeeid from ehr_compliancedb.employees p where a.employeeid = p.employeeid And p.enddate is null)
              And a.requirementname in  (select q.requirementname from ehr_compliancedb.Requirements q where q.requirementname = a.requirementname And q.dateDisabled is null )

        group by a.requirementname,a.employeeid

        UNION

        --- Additional requirements for employees that have not completed training, but is required

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
              (select h.type from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as trainee_type,      ----- type trainee, or trainer
              (select h.type from ehr_compliancedb.Requirements h where h.requirementname = j.requirementname) as requirement_type,      ----- type trainee, or trainer

              (select count(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= j.requirementname and zz.employeeid= j.employeeid  ) as timesCompleted,

                                (select k.expireperiod from ehr_compliancedb.Requirements k where k.requirementname = j.requirementname) as ExpiredPeriod,

                                ( select  (datediff(month,max(pq.date), tt.reviewdate) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   j.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = j.employeeid group by tt.expireperiod, tt.reviewdate
                                  having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate))  and (tt.reviewdate is not null)  ) as NewExpirePeriod,

                                (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= j.requirementname and zz.employeeid= j.employeeid  ) as MostRecentDate,

                                (Select distinct string_agg(yy.comment, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= j.requirementname and zz.employeeid= j.employeeid )
                                                                                                              And  yy.requirementname= j.requirementname and yy.employeeid= j.employeeid   ) as comment,

                                (Select distinct string_agg(yy.snooze_date, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= j.requirementname and zz.employeeid= j.employeeid )
                                                                                                              And  yy.requirementname= j.requirementname and yy.employeeid= j.employeeid   ) as snooze_date,

                                CAST(
                                        CASE
                                            WHEN (select max(st.date) from ehr_compliancedb.completiondates st where st.requirementname = j.requirementname and st.employeeid = j.employeeid ) IS NULL   then 0
                                            WHEN ( select  (tt.expireperiod)  from  ehr_compliancedb.requirements tt where tt.requirementname = j.requirementname   group by tt.expireperiod  ) = 0 then Null


                                            WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = j.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = j.employeeid group by tt.expireperiod, tt.reviewdate
                                                   having (tt.expireperiod) >  (datediff(month,max(pq.date), tt.reviewdate) )) > 0 THEN

                                                ( select  ( datediff(month,max(pq.date), tt.reviewdate) - (datediff(month,max(pq.date), getdate())) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   j.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = j.employeeid group by tt.expireperiod, tt.reviewdate
                                                  having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate))   )


                                            ELSE ( select  (tt.expireperiod) - ( datediff(month,max(pq.date), getdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   j.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = j.employeeid group by tt.expireperiod )

                                            END  AS DECIMAL)  AS MonthsUntilRenewal



        from  ehr_compliancedb.RequirementsPerEmployee j
          Where j.employeeid in (select p.employeeid from ehr_compliancedb.employees p where j.employeeid = p.employeeid And p.enddate is null)
          And j.requirementname in  (select q.requirementname from ehr_compliancedb.Requirements q where q.requirementname = j.requirementname And q.dateDisabled is null )

        group by j.requirementname,j.employeeid

        order by employeeid,requirementname, mostrecentcompleted_date desc


	       If @@Error <> 0
	                 GoTo Err_Proc




 RETURN 0


Err_Proc:

	RETURN 1


END

GO

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
                 having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate))   and (tt.reviewdate is not null)  ) as NewExpirePeriod,

               (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid  ) as mostrecentcompleted_date,

               (Select distinct string_agg(yy.comment, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= b.requirementname and yy.employeeid= a.employeeid   ) as comment,

               (Select distinct string_agg(yy.snooze_date, char(10)) from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= b.requirementname and zz.employeeid= a.employeeid )
                                                                                             And  yy.requirementname= b.requirementname and yy.employeeid= a.employeeid   ) as snooze_date,

               CAST(
                       CASE

                           WHEN (select max(st.date) from ehr_compliancedb.completiondates st where st.requirementname = b.requirementname and st.employeeid = a.employeeid ) IS NULL   then 0
                           WHEN ( select  (tt.expireperiod)  from  ehr_compliancedb.requirements tt where tt.requirementname = b.requirementname   group by tt.expireperiod  ) = 0 then Null


                           WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                  having (tt.expireperiod) >  ( datediff(month,max(pq.date), tt.reviewdate)        )) > 0 THEN

                               ( select  (datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())   ) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                 having (tt.expireperiod) > ( datediff(month,max(pq.date), tt.reviewdate)    )      )




                           ELSE ( select  (tt.expireperiod) - ( datediff(month,max(pq.date), getdate()) )  from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod )

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
                   having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate))  and (tt.reviewdate is not null)  ) as NewExpirePeriod,

                 (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid  ) as MostRecentDate,

                 (Select distinct string_agg(yy.comment, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid )
                                                                                                               And  yy.requirementname= a.requirementname and yy.employeeid= a.employeeid   ) as comment,

                 (Select distinct string_agg(yy.snooze_date, char(10))  from ehr_compliancedb.completiondates yy where yy.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname= a.requirementname and zz.employeeid= a.employeeid )
                                                                                                                   And  yy.requirementname= a.requirementname and yy.employeeid= a.employeeid   ) as snooze_date,

                 CAST(
                         CASE
                             WHEN (select max(st.date) from ehr_compliancedb.completiondates st where st.requirementname = a.requirementname and st.employeeid = a.employeeid ) IS NULL   then 0
                             WHEN ( select  (tt.expireperiod)  from  ehr_compliancedb.requirements tt where tt.requirementname = a.requirementname   group by tt.expireperiod  ) = 0 then Null


                             WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                    having (tt.expireperiod) >  (datediff(month,max(pq.date), tt.reviewdate)  )) > 0 THEN

                                 ( select  (datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())) ) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                   having (tt.expireperiod) > (datediff(month,max(pq.date), tt.reviewdate) )   )


                             ELSE ( select  (tt.expireperiod) - ( datediff(month,max(pq.date), getdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod )

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
               'Yes' as trackingflag,
              (select h.email from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as  email,
              (select h.lastname from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as lastname,
              (select h.firstname from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as firstname,
              (select h.majorudds from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as host,
              (select h.supervisor from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as supervisor,
              (select h.type from ehr_compliancedb.employees h where h.employeeid = j.employeeid) as trainee_type,      ----- type trainee, or trainer
              (select h.type from ehr_compliancedb.Requirements h where h.requirementname = j.requirementname) as requirement_type,    ----- type trainee, or trainer
               null as timesCompleted,
               null as ExpiredPeriod,
               null as NewExpirePeriod,
               null as MostRecentDate,
               '' as comment,
               null as snooze_date,
               null AS MonthsUntilRenewal



        from  ehr_compliancedb.RequirementsPerEmployee j
          Where j.employeeid in (select p.employeeid from ehr_compliancedb.employees p where j.employeeid = p.employeeid And p.enddate is null)
         And j.requirementname in  (select q.requirementname from ehr_compliancedb.Requirements q where q.requirementname = j.requirementname And q.dateDisabled is null )

        group by j.requirementname,j.employeeid

        order by employeeid,requirementname, mostrecentcompleted_date desc


	       If @@Error <> 0
	                 GoTo Err_Proc




 RETURN 0


Err_Proc:

	RETURN 1


END

GO

CREATE TABLE onprc_ehr_compliancedb.RequirementsPerEmployee
(
    RowId INT IDENTITY(1,1) NOT NULL,
    EmployeeId varchar(255) not null,
    RequirementName varchar(255) not null,
    CreatedBy USERID,
    Created datetime,
    ModifiedBy USERID,
    Modified datetime,
    trackingflag varchar(100)

    CONSTRAINT PK_RequirementsPerEmployeename PRIMARY KEY (RowId)
);
GO

EXEC core.fn_dropifexists 'p_ComplianceRecentOverDueSoon_Process', 'onprc_ehr_compliancedb', 'PROCEDURE';
GO

-- Author:	R. Blasa
-- Created: 9-20-2024

/*
**
** 	Created by
**      Blasa  		9-20-2024     Created a storedprocedure to create a static set of data from
**                                 the ComplianceRecentTest.sql query
**
**
**
*/

CREATE Procedure onprc_ehr_compliancedb.p_ComplianceRecentOverDueSoon_Process


AS



              ----- Reset Reporting table
              Delete onprc_ehr_compliancedb.ComplianceRecentReport

	                      If @@Error <> 0
	                                GoTo Err_Proc



BEGIN

          Insert into onprc_ehr_compliancedb.ComplianceRecentReport
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
              (select h.type from ehr_compliancedb.Requirements h where h.requirementname = b.requirementname) as requirement_type,  ----- type trainee, or trainer


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
                           WHEN ( select  (COALESCE(tt.expireperiod,0))  from  ehr_compliancedb.requirements tt where tt.requirementname = b.requirementname  group by tt.expireperiod  ) = 0 then Null


                           WHEN ( select  count(*) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                  having (tt.reviewdate) >  (max(pq.date))  ) > 0 THEN

                               ( select  (datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())) ) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                 having (tt.reviewdate) >  (max(pq.date))   )




                           ELSE ( select  (COALESCE(tt.expireperiod,0)) - ( datediff(month,max(pq.date), getdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod )

                           END  AS FLOAT)  AS MonthsUntilRenewal



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
                                  having (tt.reviewdate) >  (max(pq.date))  ) > 0 THEN

                               ( select  (datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())) ) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                 having (tt.reviewdate) >  (max(pq.date))   )


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

        UNION

        --- Training that was completed by as an employee training exemptions, and at least completed one, or more times

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
                                      having (tt.reviewdate) >  (max(pq.date)) ) > 0 THEN

                                   ( select  ( datediff(month,max(pq.date), tt.reviewdate) - (datediff(month,max(pq.date), getdate())) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                     having (tt.reviewdate) >  (max(pq.date))   )


                               ELSE ( select  (COALESCE(tt.expireperiod,0)) - ( datediff(month,max(pq.date), getdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod )

                               END  AS DECIMAL)  AS MonthsUntilRenewal


        from  ehr_compliancedb.employeerequirementexemptions a
              Where a.employeeid in (select p.employeeid from ehr_compliancedb.employees p where a.employeeid = p.employeeid And p.enddate is null)
              And a.requirementname in  (select q.requirementname from ehr_compliancedb.Requirements q where q.requirementname = a.requirementname And q.dateDisabled is null )

        group by a.requirementname,a.employeeid

        UNION

        --- Additional requirements for employees that have not completed training, but is required

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
              (select h.type from ehr_compliancedb.Requirements h where h.requirementname = j.requirementname) as requirement_type,      ----- type trainee, or trainer
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
                                  having (tt.reviewdate) >  (max(pq.date)) ) > 0 THEN

                               ( select  (datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())) ) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname = j.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = j.employeeid group by tt.expireperiod, tt.reviewdate
                                 having (tt.reviewdate) >  (max(pq.date))   )


                           ELSE ( select  (COALESCE(tt.expireperiod,0)) - ( datediff(month,max(pq.date), getdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   j.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = j.employeeid group by tt.expireperiod )

                           END  AS FLOAT)  AS MonthsUntilRenewal


        from  onprc_ehr_compliancedb.RequirementsPerEmployee j
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
                                  having (tt.reviewdate) >  (max(pq.date))  ) > 0 THEN

                               ( select  (datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())   ) )from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   b.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                 having (tt.reviewdate) >  (max(pq.date))   )


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
                                    having (tt.reviewdate) >  (max(pq.date)) ) > 0 THEN

                                 ( select  (datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())) ) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   a.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = a.employeeid group by tt.expireperiod, tt.reviewdate
                                   having (tt.reviewdate) >  (max(pq.date))  )


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
                              having (tt.reviewdate) >  (max(pq.date))  ) > 0 THEN

                           ( select  (datediff(month,max(pq.date), tt.reviewdate) - ( datediff(month,max(pq.date), getdate())) ) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where tt.requirementname =   j.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = j.employeeid group by tt.expireperiod, tt.reviewdate
                             having (tt.reviewdate) >  (max(pq.date)) )


                       ELSE ( select  (COALESCE(tt.expireperiod,0)) - ( datediff(month,max(pq.date), getdate())) from  ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq where   tt.requirementname =   j.requirementname and pq.requirementname = tt.requirementname and pq.employeeid = j.employeeid group by tt.expireperiod )

                       END  AS FLOAT)  AS MonthsUntilRenewal



        from  onprc_ehr_compliancedb.RequirementsPerEmployee j
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

EXEC core.fn_dropifexists 'p_ComplianceAccesscontainerUpdate', 'onprc_ehr_compliancedb', 'PROCEDURE';
GO

-- Author:	R. Blasa
-- Created: 10-2-2024

/*
**
** 	Created by
**      Blasa  		9-5-2025               Storedprocedure to update Compliance Access contaimer values and update
**                                         Completion date records
**                             .
**
**
**
*/

CREATE Procedure onprc_ehr_compliancedb.p_ComplianceAccesscontainerUpdate


    AS



BEGIN

          ------ Update container value and include as part of the main Compliance module

If exists(Select * from  ehr_Compliancedb.CompletionDates ss where ss.container =  'F1C05E2D-618D-103D-ABC9-9814909BFFCD' )
BEGIN

Update ss
set ss.container =   'CD170458-C55F-102F-9907-5107380A54BE'    ----Compliance folder on Prime Production

    from  ehr_Compliancedb.CompletionDates ss
Where ss.container = 'F1C05E2D-618D-103D-ABC9-9814909BFFCD'    ---Compliance Access folder on Prime Production

    If @@Error <> 0
    GoTo Err_Proc

END

ELSE             ------ No new entries exit
BEGIN

GOTO No_Records

END




No_Records:

 RETURN 0


Err_Proc:
                    -------Error Generated, Transfer process stopped
	RETURN 1


END

GO