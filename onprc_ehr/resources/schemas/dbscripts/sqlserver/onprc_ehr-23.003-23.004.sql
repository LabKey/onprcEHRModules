
CREATE TABLE [onprc_ehr].[PrimeProblemListTemp](
    [rowid] [int] IDENTITY(100,1) NOT NULL,
    [animalid] [varchar](200) NULL,
    [date] datetime NULL,
    [objectid] [varchar](4000) NULL,
    [caseid] [varchar](4000) NULL,
    [case_enddate] datetime,
    [created]  datetime


    )
    GO



-- Author:	R. Blasa
-- Created: 10-20-2022
-- Description:	Stored procedure program assigns Clinical Cases ending dates to all Clinical Problem list that
--               have no ending dates, and shares the same case ids


CREATE Procedure [onprc_ehr].[p_CaseToPRoblemListupdates]




AS



DECLARE
              @SearchKey              Int,
			  @TempsearchKey	      Int,
			  @TempObjectID           varchar(4000),
			  @TaskId		          varchar(4000),
		      @ObjectId               varchar(4000),
              @CaseEnddate            datetime,
			  @SessionID              Int




BEGIN



    ---- Reset temp table

Truncate table onprc_ehr.PrimeProblemListTemp


    If @@Error <> 0
	  GoTo Err_Proc



    --- Generate a list of Problem List records to close                         )

   Insert into onprc_ehr.PrimeProblemListTemp

    select
    b.participantid,
    b.date,
    b.objectid,
    b.caseid,
    a.enddate ,------ case ending date
    getdate()   ------ date created


     from studyDataset.c6d176_cases a, studyDataset.c6d200_problem b
    where a.objectid = b.caseid
    and a.category in ('clinical','Behavior')
    and a.qcstate = 18 and b.qcstate = 18
    and b.enddate is null
    and a.enddate is not null
    and a.participantid = b.participantid
      order by a.date desc


    If @@Error <> 0
	  GoTo Err_Proc


    ---- Reset temp variables

Set @SearchKey = 0
Set @TempSearchKey = 0
Set @TempObjectid  = NULL
Set @CaseEnddate  = NULL

----- extract initial row id

Select Top 1 @Searchkey = rowid  from onprc_ehr.PrimeProblemListTemp
Order by rowid


    While @TempSearchKey < @SearchKey
    BEGIN

                    -----Begin update process

           If exists (select * from onprc_ehr.PrimeProblemListTemp  Where rowid = @SearchKey)
            BEGIN

                 Select @TempObjectid =objectid, @CaseEnddate = case_enddate  from onprc_ehr.PrimeProblemListTemp
                  Where rowid = @Searchkey

                      -------Begin record editing process

                              Update prob
                              set prob.enddate = @CaseEnddate
                              From studyDataset.c6d200_problem prob
                              where prob.objectid = @TempObjectID


                                   If @@Error <> 0
                                    GoTo Err_Proc
            END


                    ----- Proceed and fetch the next record

                     Set @TempSearchKey = @SearchKey

                  Select Top 1 @SearchKey = rowid from onprc_ehr.PrimeProblemListTemp
                     Where rowid > @TempSearchKey
                      Order by rowid


    END ----   While @TempSearchKey


            ----- Create a master copy of the completed transaction

              Select * into onprc_ehr.PrimeProblemListMaster
                  from onprc_ehr.PrimeProblemListTemp
                      If @@Error <> 0
	  			               GoTo Err_Proc



No_Records:

 RETURN 0


Err_Proc:
                    -------Error Generated, Transfer process stopped
	RETURN 1


END

GO