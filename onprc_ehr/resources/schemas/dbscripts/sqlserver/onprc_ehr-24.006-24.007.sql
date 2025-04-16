

CREATE TABLE [onprc_ehr].[Rpt_AnimalID_Weights](
    searchid      int IDENTITY(100,1) NOT NULL,
    animalID      varchar(100) NULL,
    date         smalldatetime NULL,
    weight       decimal(12,5) NULL,
    taskId       ENTITYID NULL,
    created      smalldatetime NULL,
    createdby    smallint NULL,
    modified     smalldatetime NULL,
    modifiedby   smallint NULL

    ) ON [PRIMARY]

    GO


CREATE TABLE [onprc_ehr].[Rpt_AnimalID_WeightsMaster](
    searchid      int IDENTITY(100,1) NOT NULL,
    rowid         int,
    animalID      varchar(100) NULL,
    date         smalldatetime NULL,
    weight       decimal(12,5) NULL,
    taskId       ENTITYID NULL,
    created      smalldatetime NULL,
    createdby    smallint NULL,
    modified     smalldatetime NULL,
    modifiedby   smallint NULL,
    actual_created  smalldatetime NULL,
    remark       varchar(1000) NULL

    ) ON [PRIMARY]

    GO


/*
**
** 	Created by 		Date
**
**      Blasa  		       1-29-2025      Extract the Pathology Tissue Weights from Pathology Tissue records.
**
**                              T-00010 BODY AS A WHOLE  Tissue_Samples data set
**
**
**
**
**
**
**
*/


CREATE Procedure onprc_ehr.sp_PathologyTissueWeightsProcess
    @StartDate    SmallDateTime,
    @EndDate      SmallDateTime




    AS



DECLARE       @ReturnValue  	   Int,
			  @SearchKey           Int,
			  @TempsearchKey	   Int,
              @AnimalID            varchar(100),
              @Date                smalldatetime,
			  @RunID               varchar(4000)


Begin


				----- Reset Temp Table

				Set @Returnvalue = 0


			   ----- Reset Temp tables
			  Delete onprc_ehr.Rpt_AnimalID_Weights


				        If @@Error <> 0
		    			  GoTo Err_Proc



			Insert into onprc_ehr.Rpt_AnimalID_Weights
select
    e.participantid,
    e.date,
    e.weight,
    e.taskid,
    e.created,
    e.createdby,
    e.modified,
    e.modifiedby


from studydataset.c6d174_tissue_samples e
where e.tissue = 'T-00010'
  And (e.date >= @StartDate And e.date < Dateadd(day,1,@EndDate)  )

  and e.qcstate = 18
  and e.weight is not null
order by date desc




    If @@Error <> 0
    GoTo Err_Proc


Set @TempsearchKey = 0
Set @SearchKey = 0

Select Top 1 @Searchkey = Searchid from onprc_ehr.Rpt_AnimalID_Weights
Order by SearchID





    While @TempSearchKey < @SearchKey
    Begin

                  ---- Reset temp variables
                  Set @AnimalID = null
                  Set @Date = null
                  Set @RunID = null

                               ----Extract primary weights data from Pathology records

                 Select @Animalid = animalid, @Date = date from onprc_ehr.Rpt_AnimalID_Weights  where searchid = @Searchkey

                                                                               ---- Create Weights entries

                If not exists(select * from studydataset.c6d175_weight
                Where participantid = @AnimalID And date = @Date )


                Begin
						----- Set record object id
                                              Set @RunID = NEWID()

					        Insert into studydataset.c6d175_weight
                                                       (participantid,
                                                        date,
                                                        weight,
                                                        qcstate,
                                                        created,
                                                        createdby,
                                                        modified,
                                                        modifiedby,
                                                        taskid,
                                                        objectid,
                                                        remark,
                                                        lsid
                                                             )

                            Select @AnimalID,
                                   @Date,
                                   Rpt.weight/1000,    ----- convert weight from grams to Kilograms
                                   18,                ------ default QC State
                                   Rpt.created,
                                   Rpt.createdby,
                                   Rpt.modified,
                                   Rpt.modifiedby,
                                   Rpt.taskid,
                                   @RunID,           ------- record object id
                                   'Weight added from Path Tissue records',
                                   ' urn:lsid:ohsu.edu:Study.Data-6:1045.' + @AnimalID + '.' + format(cast(@date as date), 'yyyyMMdd') + '.0000.' + @RunID + ''



                                    from  onprc_ehr.Rpt_AnimalID_Weights Rpt
                                    where searchid = @Searchkey

                                        If @@Error <> 0
	    				                      GoTo Err_Proc



                End  ----




			            Set @TempSearchkey = @SearchKey


            Select Top 1 @Searchkey = Searchid from onprc_ehr.Rpt_AnimalID_Weights
            Where Searchid > @TempSearchkey
            Order by Searchid




    End -----(While)

                    ------- Create a Master log of entries

                        Insert into onprc_ehr.Rpt_AnimalID_WeightsMaster
                        Select j.*,
                               getdate(),    ---- record created date
                               'Pathology Tissue Weight entry'

                        from onprc_ehr.Rpt_AnimalID_Weights j


    RETURN 0

Err_Proc:

	 Return 1


END


