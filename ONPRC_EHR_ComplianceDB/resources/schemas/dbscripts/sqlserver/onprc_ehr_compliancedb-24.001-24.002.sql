



-- Author:	R. Blasa
-- Created: 2-10-2024
-- Description:	Stored procedure program process SciShield INitial Data


CREATE Procedure [onprc_ehr_compliancedb].[p_SciShieldHistoricalInitial]

AS

BEGIN

  If exists  (Select * from ehr_compliancedb.CompletionDates hh where hh.rowid in
                                                 (select a.rowid from ehr_compliancedb.CompletionDates a where
    a.date in  (select min(b.date) from ehr_compliancedb.CompletionDates b where b.requirementname = 'Safety - NHP Biosafety - Initial Training/Annual Refresher' And a.employeeid = b.employeeid and a.requirementname = b.requirementname)
    )   )
      BEGIN
        Update  hh
          set hh.requirementname = 'Safety - Non-Human Primate (NHP) Initial Biosafety Training'

         from ehr_compliancedb.CompletionDates hh where hh.rowid in
                     (select a.rowid from ehr_compliancedb.CompletionDates a where
          a.date in  (select min(b.date) from ehr_compliancedb.CompletionDates b where b.requirementname = 'Safety - NHP Biosafety - Initial Training/Annual Refresher' And a.employeeid = b.employeeid and a.requirementname = b.requirementname)
          )


        If @@Error <> 0
             GoTo Err_Proc
   END


 RETURN 0


Err_Proc:
                    -------Error Generated
	RETURN 1


END

GO



CREATE Procedure [onprc_ehr_compliancedb].[p_SciShieldHistoricalFinal]

AS

BEGIN
             --- Process final historical set for Safety - Non-Human Primate (NHP) Annual Biosafety Training

  If exists  (Select * from ehr_compliancedb.CompletionDates hh
         where hh.requirementname =  'Safety - NHP Biosafety - Initial Training/Annual Refresher')
     BEGIN

            Update  hh
                set hh.requirementname = 'Safety - Non-Human Primate (NHP) Annual Biosafety Training'
          from ehr_compliancedb.CompletionDates hh where hh.requirementname =  'Safety - NHP Biosafety - Initial Training/Annual Refresher'


                 If @@Error <> 0
                        GoTo Err_Proc
     END



                  --- Process final historical set for Safety - Chemical Safety Training - Annual

   If exists  (Select * from ehr_compliancedb.CompletionDates hh where hh.requirementname =  'Safety - Chemical Safety')
    BEGIN

            Update  hh
                     set hh.requirementname = 'Safety - Chemical Safety Training - Annual'
            from ehr_compliancedb.CompletionDates hh where hh.requirementname =  'Safety - Chemical Safety'

                         If @@Error <> 0
                                  GoTo Err_Proc
   END


            --- Process final historical set for Safety - Bioquell Z2 Vaporous Hydrogen Peroxide (VHP) Decon Unit

 If exists  (Select * from ehr_compliancedb.CompletionDates hh where hh.requirementname =  'Safety - Bioquell Z2 Vaporous Hydrogen Peroxide (VHP) Decon Unit')
  BEGIN
          Update  hh
              set hh.requirementname = 'Safety - Facility Decontamination Operator Training – Annual'

         from ehr_compliancedb.CompletionDates hh where hh.requirementname =  'Safety - Bioquell Z2 Vaporous Hydrogen Peroxide (VHP) Decon Unit'

                   If @@Error <> 0
                         GoTo Err_Proc
  END


             --- Process final historical set for Safety - ClorDiSys Minidox Chlorine Dioxide Decon Unit

 If exists  (Select * from ehr_compliancedb.CompletionDates hh where hh.requirementname =  'Safety - ClorDiSys Minidox Chlorine Dioxide Decon Unit')
  BEGIN
       update  hh
            set hh.requirementname = 'Safety - Facility Decontamination Operator Training – Annual'
       from ehr_compliancedb.CompletionDates hh where hh.requirementname =  'Safety - ClorDiSys Minidox Chlorine Dioxide Decon Unit'

                  If @@Error <> 0
                         GoTo Err_Proc
  END


RETURN 0


Err_Proc:
                    -------Error Generated
	RETURN 1


END

GO




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
          cast(getdate() as date),
          2595,
          cast(getdate() as date),
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