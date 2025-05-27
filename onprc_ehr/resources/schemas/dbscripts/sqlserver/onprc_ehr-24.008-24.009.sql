
CREATE TABLE onprc_ehr.Rpt_AnimalIDTissues(
    [Searchkey] 	[int] IDENTITY(1,1) NOT NULL,
    [animalID]      varchar(100) NULL,
    [date]          smalldatetime NULL


 ) ON [PRIMARY]
    GO

CREATE TABLE onprc_ehr.Rpt_AnimalIDTissues_Master(
    [rowid] 		[int] IDENTITY(1,1) NOT NULL,
    [SearchID]          int NULL,
    [animalID]      	varchar(100) NULL,
    [date]          	smalldatetime NULL,
    [actual_Created]  	smalldatetime NUll,
    [remarks]       	varchar(500)


 ) ON [PRIMARY]
    GO



/*
**
** 	Created by 		Date
**
**      Blasa  		        4/4/2025  Process to attached Tissues Distribution records to Patholody Tissue records
**
**

**
**
**
**
**

**
**
**
*/


CREATE Procedure [onprc_ehr].[sp_RptNecropsyTissueDistributionUpdates]
			      @StartDate    SmallDateTime,
			      @EndDate      SmallDateTime




AS



DECLARE @ReturnValue  		Int,
			  		 @SearchKey             Int,
			  		 @TempsearchKey		    Int,
			  		 @TaskId		         varchar(4000),
		          	 @ObjectId              Varchar(4000),
                     @AnimalID              varchar(100),
                     @Date                  smalldatetime,
                     @Created               smalldatetime,
                     @Createdby             smallint,
                     @modified              smalldatetime,
                     @modifiedby            smallint ,
                     @RunID                 varchar(4000)

Begin


				----- Reset Temp Table

				      Set @Returnvalue = 0



			    Delete onprc_ehr.Rpt_AnimalIDTissues


				          	 If @@Error <> 0
		    					 GoTo Err_Proc


				----Create the set of records to process

	Insert into onprc_ehr.Rpt_AnimalIDTissues
         select distinct
          e.participantid,
          e.date


from studydataset.c6d265_tissuedistributions e

Where (e.date >= @StartDate And e.date < Dateadd(day,1,@EndDate)  )
  And e.qcstate = 18
order by e.participantid, e.date



    If @@Error <> 0
		GoTo Err_Proc



Set @TempsearchKey = 0
Set @SearchKey = 0
Set @TaskID = null

Select Top 1 @Searchkey = Searchkey from onprc_ehr.Rpt_AnimalIDTissues
Order by Searchkey


    While @TempSearchKey < @SearchKey
Begin

					------ Create a task record

                                      Set @TaskID = NEWID()


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
                                      'Path Tissues ' + cast(@Date as varchar(50)) ,   	        ------ Title
                           			 'PathologyTissues',
                           			  18,                     	                     --- Qc State (In Progress)
                            		  'PathologyTissues',              	             ------ FormType
                            		   'task',                 		      -----  category,
                           			 'CD17027B-C55F-102F-9907-5107380A54BE',    ---- EHR Container
                           			  1693,                                   -------- Assigned To DCM Pathology
                           			  getdate(),                                ------- Created Date
                            			  1042, 				     -------- Created By IS
                           			  getdate(), 				     ------- Modified Date
                            			  1042				           ----- Modified by IS

                          			   )

                           			 If @@Error <> 0
                            				   GoTo Err_Proc



Select  @AnimalID = rpt.AnimalID, @Date= rpt.date, @Created=TDS.created, @Createdby= TDS.createdby, @modified = TDS.modified
from studydataset.c6d265_tissuedistributions TDS, onprc_ehr.Rpt_AnimalIDTissues Rpt
Where TDS.participantid = Rpt.AnimalID
  And TDS.date = RPT.date And Rpt.searchkey = @Searchkey


If exists (Select * from studydataset.c6d265_tissuedistributions Where participantid = @AnimalID And date = @date)
Begin
         Update TDS
         set  TDS.taskid = @TaskID

    from studydataset.c6d265_tissuedistributions TDS
Where TDS.participantid = @AnimalID
  And TDS.date = @Date


    If @@Error <> 0
    GoTo Err_Proc

End            --


		  Set @TempSearchkey = @SearchKey


Select Top 1 @Searchkey = Searchkey from onprc_ehr.Rpt_AnimalIDTissues
Where Searchkey > @TempSearchkey
Order by Searchkey


End -----(While)

                                 ------- Create a audit records

Insert into onprc_ehr.Rpt_AnimalidTissues_Master
Select *,
       getdate(),
       'Tissue Distribution entries'
from onprc_ehr.Rpt_AnimalIDTissues


 RETURN 0

Err_Proc:

	 Return 1


END

GO

