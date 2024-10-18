

/*
**
** 	Created by
**      Blasa  		3-19-2024               Import process from OccHealth Data To Prime Compliance Module
**							Introduced to this project 3-22-2024   Data file smaple provided 9-19-2024
**
**                                                 Processed codes:    Null    ---     Not Processed
                                                                          1 ------     Successfully posted
**                                                                        2 ---------  invalid Employeeid
**                                                                        3  ---------  Undefined Requirement Name
                                                                          4---------    Already exists Compliance module
                                                                          5 ------------ Undefined date string value.

*
**
**
**
Prime - Compliance Name								Sharepoint Extract
Occupational Health - Hep B Compliant - Level 1				Hep B
Occupational Health - Hep B Compliant - Level 2
Occupational Health - Measles Compliant						Measles
Occupational Health - Measles Compliant - Initial
Occupational Health - Mumps Compliant						Mumps
Occupational Health - Rubella Compliant						Rubella
Occupational Health - Varicella Compliant					Varicella
Tdap Compliant									            Tdap
Occupational Health - Respiratory Protection - CAPR Training			Full Face Respirator
Occupational Health - Respiratory Protection - N95 Respirator Fit Testing	Standard Respirator
Occupational Health - Flu Compliant						    Flu
TB Surveillance Compliant							         TB Health Surveillance
Occupational Health - TB Compliant - Annual					TB Annual
Occupational Health - TB Compliant - Initial				TB West Campus
Occupational Health - TB Compliant - Due in 6 Months
AIRC MRI Compliant								            AIRC MRI
Clinical MRI Compliant								        Clinical MRI

The following dates are not required entries:

Complete Pending (Due 04-15-2024)

Incomplete (Due 04-20-2023)

Complete by Declination (2024-03-13)

**
**
*/

                CREATE Procedure [onprc_ehr_compliancedb].[p_OccHealthToPrimeProcess]



AS



DECLARE
			              @SearchKey              Int,
			              @TempsearchKey	      Int,
			              @requirementnameFinal   varchar(2000),
                          @requirementnanme       varchar(2000),
                          @employeeid             varchar(500),
                          @Completiondate         smalldatetime,
                          @OccHealthID            int,
                          @trainer                varchar(500),
                          @Comment                varchar(2000),
  			              @HepBdate               smalldatetime,
  			              @HepB                   varchar(100),
                          @measlesDate            smalldatetime,
                          @measles                varchar(100),
                          @MumpsDate              smalldatetime,
                          @Mumps                  varchar(100),
                          @RubellaDate            smalldatetime,
                          @Rubella                varchar(100),
                          @Varicelladate          smalldatetime,
                          @Varicella              varchar(100),
                          @FullFaceRespiratordate smalldatetime,
                          @FullFaceRespirators    varchar(100),
                          @StandardRespirator     varchar(100),
			              @StandardRespiratorydate smalldatetime,
			              @Tdapdate               smalldatetime,
                          @Tdap                   varchar(100),
                          @TBWestCampusdate       smalldatetime,
                          @TBWestCampus           varchar(100),
                          @skipFlag               smallint,
                          @importTech             smallint,
                          @Status                 varchar(1000),
			              @Temp                   varchar(1000),
			              @iPos                   smallint



BEGIN



    ---- Reset temp table

         Delete onprc_ehr_compliancedb.OccHealthTemp


	 If @@Error <> 0
	  GoTo Err_Proc




    If exists(Select * from  onprc_ehr_compliancedb.OccHealth_Data  where processed is null)

     BEGIN

     Insert into onprc_ehr_compliancedb.OccHealthTemp
             (
          Email,
 	[Person Type] ,
 	[Employee Status] ,
 	[Total Compliance],
 	[Hep B] ,
    [Hep B Date],
 	[Measles] ,
    [Measles Date] ,
 	[Mumps] ,
    [Mumps Date],
 	[Rubella],
    [Rubella Date],
 	[Varicella] ,
    [Varicella Date] ,
    [Full Face Respirator] ,
    [Full Face Respirator Date] ,
    [Standard Respirator] ,
    [Standard Respirator Date] ,
    [Tdap],
    [Tdap Date),]
 	[TB West Campus] ,
    [TB West Campus Date] ,
 	[Supervisor Email],
    [processed] ,
 	[rowid]

                )


  select
     Email,
 	[Person Type] ,
 	[Employee Status] ,
 	[Total Compliance],
 	[Hep B] ,
    [Hep B Date],
 	[Measles] ,
    [Measles Date] ,
 	[Mumps] ,
    [Mumps Date],
 	[Rubella],
    [Rubella Date],
 	[Varicella] ,
    [Varicella Date] ,
    [Full Face Respirator] ,
    [Full Face Respirator Date] ,
    [Standard Respirator] ,
    [Standard Respirator Date] ,
    [Tdap],
    [Tdap Date),]
 	[TB West Campus] ,
    [TB West Campus Date] ,
 	[Supervisor Email],
    [processed] ,
 	[rowid]


              from  onprc_ehr_compliancedb.OccHealth_Data
	     where processed is null

	 order by email

      	 If @@Error <> 0
	 GoTo Err_Proc



     END

                        --- Initialize Varaibles

                       Set @TempsearchKey = 0
                       Set @SearchKey = 0



             --- Start processing input records from OccHealth


       Select top 1 @searchkey = searchID from onprc_ehr_compliancedb.OccHealthTemp
                                  order by searchID




   While @TempSearchKey < @SearchKey
   BEGIN

                              Set @requirementnanme = ''
                              Set @employeeid = ''
                              Set @Completiondate = Null
                              Set @Comment = ''
                              Set @trainer = ''
                              Set @Temp = ''
                              Set @HepBdate = Null
                              Set @HepB = ''
                              Set @measlesDate = Null
                              Set @measles = ''
                              Set @MumpsDate = Null
                              Set @Mumps = ''
                              Set @RubellaDate  = Null
                              Set @Rubella  = ''
                              Set @Varicelladate = NUll
                              Set @Varicella= ''
                              Set @FullFaceRespiratordate = NULL
                              Set @FullFaceRespirator = ''
                              Set @StandardRespiratorydate = Null
                              Set @StandardRespiratory = ''
                              Set @Tdap = ''
                              Set @Tdapdate = NUll
                              Set @TBWestCampus = ''
                              Set @TBWestCampusdate = Null
                              Set @OccHealthID  = Null
			                  Set @skipFlag = 0
                              Set @ImportTech = 3054    ---Pete Johnson
                              Set @Status = ''
							  Set @iPos = 0






                   Select @employeeid = trim(email),  @HepBdate = trim([hep B Date]), @HepBdate = trim([hep B]), @measlesDate = trim([Measles Date]), @MumpsDate = trim([Mumps Date]), @RubellaDate = trim([Rubella Date]),
                             @Varicelladate= trim([Varicella Date]), @FullFaceRespiratordate = trim([Full Face Respirator Date]), @FullFaceRespirator= trim([Full Face Respirator]), @StandardRespiratorydate = trim([Standard Respirator Date]),
                               @Tdap = tgrim([Tdap]), @Tdapdate = trim(Tdap Date])@TBWestCampusdate = trim([TB West Campus Date]),
                            @trainer = trim([supervisor email]),@OccHealthID = rowid

                               from onprc_ehr_compliancedb.OccHealthTemp Where  searchID = @Searchkey


                            -----Parse and extract date from file`

		      Set @iPos = charindex('@', @employeeid)
              if @iPos > 0
			   Begin
                          Set @employeeid = left(@employeeid,@iPos - 1)
		        End


			         Set @iPos = charindex('@', @trainer)

              if @iPos > 0
			  Begin
			       Set @trainer = left(@trainer,@iPos - 1)
               End

                                    ----validate if the employeeid is defined

               IF not exists( Select * from ehr_compliancedb.employees Where employeeid = @employeeid And enddate is null)

                   BEGIN
                            Set @Status = ''
				            Set @Status = @Status + 'Employee ID Undefined '

                            Update ss
                               Set ss.processed = @Status

                              From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        If @@Error <> 0
	                                GoTo Err_Proc

                                    GOTO Next_Record


                 END  ----


						----Evaluate Hep B data

                  If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Hep B Date] is not null)
                     BEGIN

                          Select  @HepBdate = trim([Hep B Date]), @Herp= trim([Herp]) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Hep B Date] is not null

                             Set  @comment = ''
                             Set @Temp = ''

  			                 If ( @Herp = 'Complete)
                                 Set @comment = @comment + ' Complete'


                      If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = 'Occupational Health - Hep B Compliant - Level 1'
                                    And date = @HepBdate And @HepBdate is not null)

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
           			  		   modifiedby,
                               comment

         					)
        				values(
         				        @employeeid,
          			            'Occupational Health - Hep B Compliant - Level 1',
          			            @HepBdate,
          			            @trainer,
          			            'CD170458-C55F-102F-9907-5107380A54BE',
          			             getdate(),
         			             @ImportTech,
          			             getdate(),
          			             @ImportTech,
					             @comment
									)



                                                    If @@Error <> 0
	                               				 GoTo Err_Proc


					---------- Set successful entry flag

						Set @Status = @Status + 'Processed'

			   			 Update ss
                               				Set ss.processed =  @Status

                              			From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                                			GoTo Err_Proc


			             END   -----if not exists


                   END  ---If exists





                                ----Evaluate Measles data

            If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Measles Date] is not null)
               BEGIN

                    Select  @Measlesdate = trim([Measles Date]), @Measles= trim([Measles]) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Measles Date] is not null

                       Set @comment = ''

                    If ( @Measles = 'Complete)
                               Set @comment = @comment + ' Complete'
                     else
                                Set @comment = @comment + ' Complete by Declination'

                    If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = 'Occupational Health - Measles Compliant'
                                              And date = @Measlesdate   And @Measlesdate is not null

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
                     			  		   modifiedby,
                                         comment

                   					)
                  				values(
                   				        @employeeid,
                    			        'Occupational Health - Measles Compliant',
                    			         @Measlesdate,
                    			         @trainer,
                    			         'CD170458-C55F-102F-9907-5107380A54BE',
                    			          getdate(),
                   			             @ImportTech,
                    			         getdate(),
                    			         @ImportTech,
          					             @comment
          									)



                                                              If @@Error <> 0
          	                               				 GoTo Err_Proc


          					---------- Set successful entry flag

          						Set @Status = @Status + 'Processed'

          			   			 Update ss
                                        Set ss.processed =  @Status

                                   From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


                	                       If @@Error <> 0
          	                                GoTo Err_Proc


          			             END   -----if not exists


                             END  ---If exists




                  ----Evaluate Mumps data

            If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Mumps Date] is not null)
               BEGIN

                    Select  @Mumpsdate = trim([Mumps Date]), @Mumps= trim([Mumps]) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Mumps Date] is not null

                         Set @comment = ''

                    If ( @Mumps = 'Complete)
                               Set @comment = @comment + ' Complete'
                     else
                                Set @comment = @comment + ' Complete by Declination'

                    If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = 'Occupational Health - Mumps Compliant'
                                              And date = @Mumpsdate   And @Mumpsdate is not null

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
                     			  		   modifiedby,
                                         comment

                   					)
                  				values(
                   				        @employeeid,
                    			        'Occupational Health - Mumps Compliant',
                    			         @Mumpsdate,
                    			         @trainer,
                    			         'CD170458-C55F-102F-9907-5107380A54BE',
                    			          getdate(),
                   			             @ImportTech,
                    			         getdate(),
                    			         @ImportTech,
          					             @comment
          									)



                                                              If @@Error <> 0
          	                               				 GoTo Err_Proc


          					---------- Set successful entry flag

          						Set @Status = @Status + 'Processed'

          			   			 Update ss
                                        Set ss.processed =  @Status

                                   From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


                	                       If @@Error <> 0
          	                                GoTo Err_Proc


          			             END   -----if not exists


                             END  ---If exists



                  ----Evaluate Rubella data

            If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Rubella Date] is not null)
               BEGIN

                    Select  @Rubelladate = trim([Measles Date]), @Rubella= trim([Rubella]) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Mumps Date] is not null

                         Set @comment = ''

                    If ( @Rubella = 'Complete)
                               Set @comment = @comment + ' Complete'
                     else
                                Set @comment = @comment + ' Complete by Declination'

                    If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = 'Occupational Health - Rubella Compliant'
                                              And date = @Rubelladate   And @Rubelladate is not null

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
                     			  		   modifiedby,
                                         comment

                   					)
                  				values(
                   				        @employeeid,
                    			        'Occupational Health - Rubella Compliant',
                    			         @Rubelladate,
                    			         @trainer,
                    			         'CD170458-C55F-102F-9907-5107380A54BE',
                    			          getdate(),
                   			             @ImportTech,
                    			         getdate(),
                    			         @ImportTech,
          					             @comment
          									)



                                                              If @@Error <> 0
          	                               				 GoTo Err_Proc


          					---------- Set successful entry flag

          						Set @Status = @Status + 'Processed'

          			   			 Update ss
                                        Set ss.processed =  @Status

                                   From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


                	                       If @@Error <> 0
          	                                GoTo Err_Proc


          			             END   -----if not exists


                             END  ---If exists




                  ----Evaluate Varicella data

            If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Rubella Date] is not null)
               BEGIN

                    Select  @Varicelladate = trim([Varicella Date]), @Rubella= trim([Varicella]) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Varicella Date] is not null

                         Set @comment = ''

                    If ( @Varicella = 'Complete)
                               Set @comment = @comment + ' Complete'
                     else
                                Set @comment = @comment + ' Complete by Declination'

                    If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = 'Occupational Health - Varicella Compliant'
                                              And date = @Varicelladate   And @Varicelladate is not null

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
                     			  		   modifiedby,
                                           comment

                   					)
                  				values(
                   				        @employeeid,
                    			        'Occupational Health - Varicella Compliant',
                    			         @Varicelladate,
                    			         @trainer,
                    			         'CD170458-C55F-102F-9907-5107380A54BE',
                    			          getdate(),
                   			             @ImportTech,
                    			         getdate(),
                    			         @ImportTech,
          					             @comment
          									)



                                                              If @@Error <> 0
          	                               				 GoTo Err_Proc


          					---------- Set successful entry flag

          						Set @Status = @Status + 'Processed'

          			   			 Update ss
                                        Set ss.processed =  @Status

                                   From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


                	                       If @@Error <> 0
          	                                GoTo Err_Proc


          			             END   -----if not exists


                             END  ---If exists


                  ----Evaluate Full Face Respirator data

            If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Full Face Respirator Date] is not null)
               BEGIN

                    Select  @FullfaceRespiratordate = trim([Full Face Respirator Date]), @FullFaceRespirator = trim([Full Face Respirator]) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Full Face Respirator Date] is not null

                         Set @comment = ''

                    If ( @FullFaceRespirator = 'Complete)
                               Set @comment = @comment + ' Complete'
                     else
                                Set @comment = @comment + ' Complete by Declination'

                    If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = 'Occupational Health - Respiratory Protection - CAPR Training'
                                              And date = @FullFaceRespiratordate   And @FullFaceRespiratordate is not null

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
                     			  		   modifiedby,
                                           comment

                   					)
                  				values(
                   				        @employeeid,
                    			        'Occupational Health - Respiratory Protection - CAPR Training',
                    			         @FullFaceRespiratordate,
                    			         @trainer,
                    			         'CD170458-C55F-102F-9907-5107380A54BE',
                    			          getdate(),
                   			             @ImportTech,
                    			         getdate(),
                    			         @ImportTech,
          					             @comment
          									)



                                                              If @@Error <> 0
          	                               				 GoTo Err_Proc


          					---------- Set successful entry flag

          						Set @Status = @Status + 'Processed'

          			   			 Update ss
                                        Set ss.processed =  @Status

                                   From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


                	                       If @@Error <> 0
          	                                GoTo Err_Proc


          			             END   -----if not exists


                             END  ---If exists



                ----Evaluate Standard Respiratordata

            If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Standard Respirator Date] is not null)
               BEGIN

                    Select  @StandardRespiratordate = trim([Stamdard Respirator Date]), @StandardRespirator= trim([Standard Respirator]) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Standard Respirator Date] is not null

                        Set @comment = ''

                    If ( @StandardRespirator = 'Complete)
                               Set @comment = @comment + ' Complete'
                     else
                                Set @comment = @comment + ' Complete by Declination'

                    If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = 'Occupational Health - Respiratory Protection - N95 Respirator Fit Testing'
                                              And date = @StandardRespiratordate   And @StarndardRespiratordate is not null

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
                     			  		   modifiedby,
                                           comment

                   					)
                  				values(
                   				        @employeeid,
                    			        'Occupational Health - Respiratory Protection - N95 Respirator Fit Testing',
                    			         @Measlesdate,
                    			         @trainer,
                    			         'CD170458-C55F-102F-9907-5107380A54BE',
                    			          getdate(),
                   			             @ImportTech,
                    			         getdate(),
                    			         @ImportTech,
          					             @comment
          									)



                                                              If @@Error <> 0
          	                               				 GoTo Err_Proc


          					---------- Set successful entry flag

          						Set @Status = @Status + 'Processed'

          			   			 Update ss
                                        Set ss.processed =  @Status

                                   From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


                	                       If @@Error <> 0
          	                                GoTo Err_Proc


          			             END   -----if not exists


                             END  ---If exists

                        ----Evaluate Tdap Values

            If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Tdap Date] is not null)
               BEGIN

                    Select  @Tdapdate = trim([Tdap Date]), @Tdap= trim([Tdap]) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Tdap Date] is not null

                       Set @comment = ''

                    If ( @Tdab = 'Complete)
                               Set @comment = @comment + ' Complete'
                     else
                                Set @comment = @comment + ' Complete by Declination'

                    If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = 'Tdap Compliant'
                                              And date = @Tdapdate   And @Tdapdate is not null

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
                     			  		   modifiedby,
                                           comment

                   					)
                  				values(
                   				        @employeeid,
                    			        'Tdap Compliant',
                    			         @Tdaoate,
                    			         @trainer,
                    			         'CD170458-C55F-102F-9907-5107380A54BE',
                    			          getdate(),
                   			             @ImportTech,
                    			         getdate(),
                    			         @ImportTech,
          					             @comment
          									)



                                                              If @@Error <> 0
          	                               				 GoTo Err_Proc


          					---------- Set successful entry flag

          						Set @Status = @Status + 'Processed'

          			   			 Update ss
                                        Set ss.processed =  @Status

                                   From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


                	                       If @@Error <> 0
          	                                GoTo Err_Proc


          			             END   -----if not exists


                             END  ---If exist


                ----Evaluate TB West Campus

            If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [TB West Campus Date] is not null)
               BEGIN

                    Select  @TBWestCampusdate = trim([TB West Campus Date]), @TBWestCampus= trim([TB West Campus]) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [TB West Campus Date] is not null

                       Set @comment = ''

                    If ( @TbWestCampus = 'Complete'
                               Set @comment = @comment + ' Complete'
                     else
                                Set @comment = @comment + ' Complete by Declination'

                    If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = 'Occupational Health - TB Compliant - Initial'
                                              And date = @TBWestCampusdate   And @TBWestCampusdate is not null

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
                     			  		   modifiedby,
                                           comment

                   					)
                  				values(
                   				        @employeeid,
                    			        'Occupational Health - TB Compliant - Initial',
                    			         @Measlesdate,
                    			         @trainer,
                    			         'CD170458-C55F-102F-9907-5107380A54BE',
                    			          getdate(),
                   			             @ImportTech,
                    			         getdate(),
                    			         @ImportTech,
          					             @comment
          									)



                                                              If @@Error <> 0
          	                               				 GoTo Err_Proc


          					---------- Set successful entry flag

          						Set @Status = @Status + 'Processed'

          			   			 Update ss
                                        Set ss.processed =  @Status

                                   From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


                	                       If @@Error <> 0
          	                                GoTo Err_Proc


          			             END   -----if not exists


                             END  ---If exist




Next_Record:



	                      Set @TempSearchkey = @SearchKey


	                 Select Top 1 @Searchkey = searchID  from onprc_ehr_compliancedb.OccHealthTemp
				Where searchID > @TempSearchkey
				     Order by searchID



    END  ---(While)








     ---- Create a master records of the last most recent entries
    If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp)
      BEGiN
              Insert into onprc_ehr_compliancedb.OccHealthMasterTemp
	     select
	          Email,
          	 [Person Type] ,
          	 [Employee Status] ,
          	 [Total Compliance],
          	 [Hep B] ,
             [Hep B Date],
          	 [Measles] ,
             [Measles Date] ,
          	 [Mumps] ,
             [Mumps Date],
          	 [Rubella],
             [Rubella Date],
          	 [Varicella] ,
             [Varicella Date] ,
             [Full Face Respirator] ,
             [Full Face Respirator Date] ,
             [Standard Respirator] ,
             [Standard Respirator Date] ,
             [Tdap],
             [Tdap Date),]
          	 [TB West Campus] ,
             [TB West Campus Date] ,
          	 [Supervisor Email],
             [processed] ,
          	 [rowid]



                   from onprc_ehr_compliancedb.OccHealthTemp


      	        If @@Error <> 0
	                GoTo Err_Proc
      END






No_Records:

 RETURN 0


Err_Proc:
                    -------Error Generated, Transfer process stopped
	RETURN 1


END

