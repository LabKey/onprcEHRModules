
-- Created: 7-17-2024  R. Blasa

CREATE TABLE [onprc_ehr_compliancedb].[ComplianceTemp](
    [rowid] [int] IDENTITY(100,1) NOT NULL,
    [employeeid] [varchar](500) NULL,
    [trainingname] [varchar](1000) NULL

    )
    GO


CREATE TABLE [onprc_ehr_compliancedb].[ComplianceEditorMaster](
    [employeeid] [varchar](1000) NULL,
    [date] datetime NULL,
    [trainingname] [varchar](4000) NULL,
    [created]  datetime,
    [createdby] smallint,
    [trainer]   varchar(1000) null,
    [result]   varchar(1000) null,
    [comment] varchar(3000) null,
    [filename] varchar(1000) null,
    [snooze_date] smalldatetime


    )
    GO
/*
**
**   	Created by
**      R. Blasa         7/18/2024          Program Process to Insert a Compliance CompletionDate record through SSRS program.
**
**
**
**
**
**
**
**
*/

CREATE Procedure [onprc_ehr_compliancedb].[p_ComplianceEditor]
                             @date              smalldatetime,
                             @trainer          varchar(1000),
                             @createdby        smallint,
                             @result           varchar(1000),
                             @comment          varchar(3000),
                             @filename         varchar(1000),
                             @snooze_date      smalldatetime






AS



DECLARE

              @TempIdkey               smallint,
              @Idkey                   smallint,
			  @employeeid              varchar(500),
			  @TrainingName            varchar(2000)




BEGIN


                 --- Reset temp table


			Set @TempIDkey = 0
            Set @Idkey = 0


			------ Exit early if no records to process
	 IF (select count(*) from [onprc_ehr_compliancedb].[ComplianceTemp]) = 0
     BEGIN
        GoTo  No_Records
     END




    select Top 1 @Idkey = rowid from [onprc_ehr_compliancedb].[ComplianceTemp]

        Order by rowid

    While @TempIDkey < @IdKey
    Begin

                          ----- Initialize Training Requirements Variables

       Select  @employeeid =employeeid, @TrainingName = trainingname from [onprc_ehr_compliancedb].[ComplianceTemp]
        Where rowid = @Idkey
          Order by rowid


    --- Create a new record

    Insert into ehr_compliancedb.CompletionDates
         (employeeid,
         requirementname,
         date,
         container,
         created,
         createdby,
         trainer,
         result,
         comment,
         filename,
         snooze_date

        )
     values
    (
         @employeeid,
         @TrainingName,
         @date,              			---------Completed date
        'CD170458-C55F-102F-9907-5107380A54BE',   -----Compliance Container
         getdate(),                               ----date created
         @createdby,
          @trainer,                               ---- Employee trainer
          @result,
          @comment,
          @filename,
          @snooze_date

       )

         If @@Error <> 0
                  GoTo Err_Proc


                Set @TempIDkey = @Idkey



            select Top 1 @Idkey = rowid from [onprc_ehr_compliancedb].[ComplianceTemp]
            Where rowid > @TempIdkey
            Order by rowid


       END   ----- ( While @TempIDkey < @IdKey)



            ----- Create a master copy of the completed transaction

        /*     Insert into onprc_ehr_compliancedb.[ComplianceEditorMaster]
                       select employeeid,
                              date,
                              requirementname,
                              created,
                              createdby,
                              trainer,
                               result,
                               comment,
                               filename,
                               snooze_date

                           from  ehr_compliancedb.CompletionDates
                           Where created >= cast(getdate() as date)


			If @@Error <> 0
	  			GoTo Err_Proc   */

 				--- Reset temp table

             truncate table [onprc_ehr_compliancedb].[ComplianceTemp]

                 If @@Error <> 0
                         GoTo Err_Proc

            ---- Display all the entries that were added

                Select    a.employeeid [employeeid],
                          a.requirementname [requirementname],
                          a.date [date],
                          a.created [created],
                         (select   (b.lastname + ', ' + b.firstname)  from  onprc_ehr.usersActiveNames b where a.createdby =b.userid) as createdBy,
                         a.trainer [trainer],
                         a.result,
                         a.comment,
                         a.filename,
                         a.snooze_date [Snooze Until]


                   from  ehr_compliancedb.CompletionDates a
                   Where a.created >= cast(getdate() as date)

                            If @@Error <> 0
                                GoTo Err_Proc



                ------ Rest Temp table
                Delete [onprc_ehr_compliancedb].[ComplianceTemp]

			            If @@Error <> 0
	  		                    GoTo Err_Proc




No_Records:

 RETURN 0


Err_Proc:
                    -------Error Generated, process stopped
	RETURN 1


END

GO

