
CREATE TABLE [onprc_ehr].[TB_TestHistoricalTemp](
    [rowid] [int] IDENTITY(100,1) NOT NULL,
     animalid      varchar(200) NULL,
     date          datetime NULL,
     objectid      ENTITYID NOT NULL,
     created       datetime NULL,
     createdby     integer NULL,
     performedby   varchar(200) NULL


    )
    GO

CREATE TABLE [onprc_ehr].[TB_TestHistoricalTempMaster](
    rowid         integer ,
    animalid     varchar(200) NULL,
    date         datetime NULL,
    objectid     ENTITYID NOT NULL,
    created      datetime NULL,
    createdby    integer NULL,
    performedby  varchar(200) NULL

  )
    GO


/*
**
** 	Created by
**      R. Blasa   9-25-2024                 A  Program Process that reviews all TB Test entries form 1/1/2024 to the current date, and then creates a
**                                               new TB Test Clinical Observation record based on

*/

  CREATE Procedure onprc_ehr.p_Create_TB_ObservationHistoricalrecords
                         @starting_date  smalldatetime,
                         @ending_date     smalldatetime



    AS



DECLARE
              @SearchKey              Int,
			  @TempsearchKey	      Int,
			  @TaskId		          varchar(4000),
		      @ObjectId               varchar(4000),
              @AnimalID               varchar(100),
              @date                   datetime,
              @createdby              smallint,
              @created                smalldatetime,
			  @performedby            varchar(200),
              @RunID                 varchar(4000)




BEGIN



    ---- Reset temp table

Truncate table onprc_ehr.TB_TestHistoricalTemp


    If @@Error <> 0
	  GoTo Err_Proc


    --- Generate a list TB test monkeys                        )

     Insert into onprc_ehr.TB_TestHistoricalTemp

select
    a.participantid,
    a.date,
    a.objectid,
    a.created,
    a.createdBy,
    a.performedby





    from studydataset.c6d214_encounters  a
    Where a.participantid not in (select b.participantid  from studydataset.c6d171_clinical_observations b
                                  where a.participantid = b.participantid
                                   And cast(b.date as date)  = dateadd(day,3,cast(a.date as date))
                                   And b.category = 'TB TST Score (72 hr)'
                                     And (a.date >= @starting_date and a.date < dateadd(day,1,cast(@ending_date as date) ) )
                                     And a.type = 'Procedure' And a.qcstate = 18 And a.procedureid = 802   )

      And a.type = 'Procedure' And a.qcstate = 18 And a.procedureid = 802         -----'TB Test Intradermal'
      And (a.date >= @starting_date and a.date < dateadd(day,1,cast(@ending_date as date) )  )
    And a.participantid in ( select k.participantid from studydataset.c6d203_demographics k
        where k.calculated_status = 'alive')

    order by a.participantid, a.date desc



    If @@Error <> 0
	 		 GoTo Err_Proc

        ---- When there are no records to process, exit immediately from the program.

    If (Select count(*) from onprc_ehr.TB_TestHistoricalTemp) = 0
    BEGIN
    GOTO No_Records
    END


    ---- Reset temp variables

          Set @SearchKey = 0
          Set @TempSearchKey = 0
          Set @Date = NULL
          Set @created = NULL
          Set @createdby =NULL
          Set @performedby = NULL
          Set @TaskID = NULL
          Set @Animalid = Null
          Set @RunID   = Null



      ----- extract initial row id

        Select Top 1 @Searchkey = rowid  from onprc_ehr.TB_TestHistoricalTemp
        Order by rowid


                    Set @TaskID = NEWID()         ----- Task Record Object ID

                    ----Create a single task for each daily process


                            Insert into EHR.Tasks
                        (
                            taskid,
                            description,
                            title,
                            qcstate,
                            formType,
                            category,
                            container,
                            assignedto,
                            created,
                            createdby,
                            modified,
                            modifiedby

                        )

                        Values  (

                            @TaskID,
                            'TB TST Scores ' + cast(@Date as varchar(50)) ,   	        ------ Title  consist of animal id and Clinical procedure date
                            'TB TST Scores',
                            20,                     	              --- Qc State (In Progress)
                            'TB TST Scores',              	      ------ FormType
                            'task',                 		      -----  category,
                            'CD17027B-C55F-102F-9907-5107380A54BE',    ---- EHR Container
                            1822,                               -------- Assigned To Data Admins
                            getdate(),                                ------- Create Date
                            1042, 				     -------- Created By IS
                            getdate(), 				     ------- Modified Date
                            1042				     ----- Modified by IS

                            )

                            If @@Error <> 0
                               GoTo Err_Proc



    While @TempSearchKey < @SearchKey
    BEGIN

                    -----Begin entry Tb observation process

       Select @Animalid =animalid, @date = date, @created =created, @createdby =createdby,@performedby= performedby from onprc_ehr.TB_TestHistoricalTemp Where rowid = @Searchkey

    If not exists (select * from studydataset.c6d171_clinical_observations j Where j.participantid  = @AnimalID
                                             And cast(j.date as date) = dateadd(day,3,cast(@date as date)) And j.category = 'TB TST Score (72 hr)'   )
    BEGIN



               ----- Initialize data entries
                Set @RunID = NEWID()          ---- ObjectID
                Set @date = dateadd(day, 3,@date)  ----- Add three days from TB Test date



               --- Create a Clinical Observation Record

                Insert into studydataset.c6d171_clinical_observations
                        (
                          participantid,
                          date,
                          category,
                          area,
                          observation,
                          created,
                          createdby,
                          performedby,
                          objectid,
                          taskid,
                          qcstate,
                          modified,
                          modifiedby,
                          lsid

                           )
                      values (
                          @animalid,
                          @date,
                          'TB TST Score (72 hr)',
                         'Right Eyelid',
                         'Grade: Negative',
                          getdate(),                         ----- created
                          @createdby,
                          @performedby,
                           @RunID ,                                    ----- Objectid
                           @TaskID,
                            20 ,                                     ---- In Progress QCState
                            getdate(),                         -----modified
                            @createdBy,
                            'urn:lsid:ohsu.edu:Study.Data-6:5006.10003.19810204.0000.' + '' + @RunID + ''

            )

                             If @@Error <> 0
                                  GoTo Err_Proc



END


             ----- Proceed and fetch the next record

                Set @TempSearchKey = @SearchKey

Select Top 1 @SearchKey = rowid from onprc_ehr.TB_TestHistoricalTemp
Where rowid > @TempSearchKey
Order by rowid


END ----   While @TempSearchKey


            ----- Create a master copy of the completed transaction

  Insert into onprc_ehr.TB_TestHistoricalTempMaster
     Select *  from onprc_ehr.TB_TestHistoricalTemp

         If @@Error <> 0
	  			GoTo Err_Proc



No_Records:

 RETURN 0


Err_Proc:
                    -------Error Generated, program processed stopped
	RETURN 1


END

GO








