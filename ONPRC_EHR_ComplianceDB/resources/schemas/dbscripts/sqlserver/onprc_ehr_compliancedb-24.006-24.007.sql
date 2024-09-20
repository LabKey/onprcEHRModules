

/*
**
** 	Created by
**      Blasa  		3-19-2024               Import process from OccHealth Data To Prime Compliance Module
**							Introduced to this project 3-22-2024   Data file smaple provided 3-22-2024
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
Occupational Health - Hep B Compliant - Level 1					Hep B
Occupational Health - Hep B Compliant - Level 2
Occupational Health - Measles Compliant						Measles
Occupational Health - Measles Compliant - Initial
Occupational Health - Mumps Compliant						Mumps
Occupational Health - Rubella Compliant						Rubella
Occupational Health - Varicella Compliant					Varicella
Tdap Compliant									Tdap
Occupational Health - Respiratory Protection - CAPR Training			Full Face Respirator
Occupational Health - Respiratory Protection - N95 Respirator Fit Testing	Standard Respirator
Occupational Health - Flu Compliant						Flu
TB Surveillance Compliant							TB Health Surveillance
Occupational Health - TB Compliant - Annual					TB Annual
Occupational Health - TB Compliant - Initial					TB West Campus
Occupational Health - TB Compliant - Due in 6 Months
AIRC MRI Compliant								AIRC MRI
Clinical MRI Compliant								Clinical MRI

The following dates are not required entries:

Complete Pending (Due 04-15-2024)

Incomplete (Due 04-20-2023)

Complete by Declination (2024-03-13)









CREATE TABLE [onprc_ehr_complinacedb].[OccHealthTemp](
	[searchID] [int] IDENTITY(100,1) NOT NULL,
	[Email] [nvarchar](255) NULL,
	[Person Type] [nvarchar](255) NULL,
	[Employee Status] [nvarchar](255) NULL,
	[Total Compliance] [nvarchar](255) NULL,
	[West Campus] [nvarchar](255) NULL,
	[Hep B] [nvarchar](255) NULL,
	[Measles] [nvarchar](255) NULL,
	[Mumps] [nvarchar](255) NULL,
	[Rubella] [nvarchar](255) NULL,
	[Varicella] [nvarchar](255) NULL,
	[Tdap] [nvarchar](255) NULL,
	[Full Face Respirator] [nvarchar](255) NULL,
	[Standard Respirator] [nvarchar](255) NULL,
	[Flu] [nvarchar](255) NULL,
	[TB Health Surveillance] [nvarchar](255) NULL,
	[TB Annual] [nvarchar](255) NULL,
	[TB West Campus] [nvarchar](255) NULL,
	[AIRC MRI] [nvarchar](255) NULL,
	[Clinical MRI] [nvarchar](255) NULL,
	[Supervisor Email] [nvarchar](255) NULL,
        [trainer] [varchar](1000) NULL,
        [processed]  [varchar](1000) NULL,
	[rowid] [int] NULL

) ON [PRIMARY]
GO

CREATE TABLE [onprc_ehr_complinacedb].[OccHealthMasterTemp](
	[searchID] [int] IDENTITY(100,1) NOT NULL,
	[Email] [nvarchar](255) NULL,
	[Person Type] [nvarchar](255) NULL,
	[Employee Status] [nvarchar](255) NULL,
	[Total Compliance] [nvarchar](255) NULL,
	[West Campus] [nvarchar](255) NULL,
	[Hep B] [nvarchar](255) NULL,
	[Measles] [nvarchar](255) NULL,
	[Mumps] [nvarchar](255) NULL,
	[Rubella] [nvarchar](255) NULL,
	[Varicella] [nvarchar](255) NULL,
	[Tdap] [nvarchar](255) NULL,
	[Full Face Respirator] [nvarchar](255) NULL,
	[Standard Respirator] [nvarchar](255) NULL,
	[Flu] [nvarchar](255) NULL,
	[TB Health Surveillance] [nvarchar](255) NULL,
	[TB Annual] [nvarchar](255) NULL,
	[TB West Campus] [nvarchar](255) NULL,
	[AIRC MRI] [nvarchar](255) NULL,
	[Clinical MRI] [nvarchar](255) NULL,
	[Supervisor Email] [nvarchar](255) NULL,
        [trainer] [varchar](1000) NULL,
        [processed]   [varchar](1000) NULL,
	[rowid] [int] NULL

) ON [PRIMARY]
GO


**
**



CREATE TABLE [onprc_ehr_compliancedb].[OccHealth_Data](
        [RowId] [int] IDENTITY(100,1) NOT NULL,
	[Email] [nvarchar](255) NULL,
	[Person Type] [nvarchar](255) NULL,
	[Employee Status] [nvarchar](255) NULL,
	[Total Compliance] [nvarchar](255) NULL,
	[West Campus] [nvarchar](255) NULL,
	[Hep B] [nvarchar](255) NULL,
	[Measles] [nvarchar](255) NULL,
	[Mumps] [nvarchar](255) NULL,
	[Rubella] [nvarchar](255) NULL,
	[Varicella] [nvarchar](255) NULL,
	[Tdap] [nvarchar](255) NULL,
	[Full Face Respirator] [nvarchar](255) NULL,
	[Standard Respirator] [nvarchar](255) NULL,
	[Flu] [nvarchar](255) NULL,
	[TB Health Surveillance] [nvarchar](255) NULL,
	[TB Annual] [nvarchar](255) NULL,
	[TB West Campus] [nvarchar](255) NULL,
	[AIRC MRI] [nvarchar](255) NULL,
	[Clinical MRI] [nvarchar](255) NULL,
	[Supervisor Email] [nvarchar](255) NULL,
        [trainer] [varchar](1000) NULL,
        [processed]   [varchar](1000) NULL,

) ON [PRIMARY]
GO

*/

                                 CREATE Procedure [onprc_ehr_compliancedb].[p_OccHealthToPrimeProcess]



AS



DECLARE
			  @SearchKey              Int,
			  @TempsearchKey	  Int,
			  @requirementnameFinal   varchar(2000),
                          @requirementnanme       varchar(2000),
                          @employeeid             varchar(500),
                          @Completiondate         smalldatetime,
                          @OccHealthID            int,
                          @trainer                varchar(1000),
                          @Comment                varchar(2000),
  			  @HerpesBdate            varchar(500),
                          @measlesDate            varchar(500),
                          @MumpsDate              varchar(500),
                          @RubellaDate            varchar(500),
                          @Varicelladate          varchar(500),
     			  @Tdapdate               varchar(500),
                          @Fullfacerespiratordate varchar(500),
			  @StandardRespiratorydate varchar(500),
                          @Fludate                varchar(500),
                          @TBSurveillancedate     varchar(500),
                          @TBAnnualdate           varchar(500),
                          @TBWestCampusdate       varchar(500),
			  @ClinicalMRI_date       varchar(500),
                          @AIRCMRI_date           varchar(500),
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
	[West Campus] ,
	[Hep B] ,
	[Measles] ,
	[Mumps] ,
	[Rubella],
	[Varicella] ,
	[Tdap] ,
	[Full Face Respirator] ,
	[Standard Respirator] ,
	[Flu] ,
	[TB Health Surveillance] ,
	[TB Annual] ,
	[TB West Campus] ,
	[AIRC MRI] ,
	[Clinical MRI],
	[Supervisor Email],
        [processed] ,
	[rowid]

               )


           select
                 Email,
	[Person Type] ,
	[Employee Status] ,
	[Total Compliance],
	[West Campus] ,
	[Hep B] ,
	[Measles] ,
	[Mumps] ,
	[Rubella],
	[Varicella] ,
	[Tdap] ,
	[Full Face Respirator] ,
	[Standard Respirator] ,
	[Flu] ,
	[TB Health Surveillance] ,
	[TB Annual] ,
	[TB West Campus] ,
	[AIRC MRI] ,
	[Clinical MRI],
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
			      Set  @requirementnameFinal = ''
                              Set @requirementnanme = ''
                              Set @employeeid = ''
                              Set @Completiondate = Null
                              Set @Comment = ''
                              Set @trainer = ''
                              Set @Temp = ''
                              Set @HerpesBdate = Null
                              Set @measlesDate = Null
                              Set @MumpsDate = Null
                              Set @RubellaDate  = Null
                              Set @Varicelladate = NUll
     			      Set @Tdapdate = Null
                              Set @Fullfacerespiratordate = Null
                              Set @StandardRespiratorydate = Null
                              Set @Fludate = Null
                              Set @TBSurveillancedate = Null
                              Set @TBAnnualdate = Null
                              Set @TBWestCampusdate = Null
                              Set @OccHealthID  = Null
                              Set @ClinicalMRI_date = Null
                              Set @AIRCMRI_date = Null
			      Set @skipFlag = 0
                              Set @ImportTech = 3054    ---Pete Johnson
                              Set @Status = ''
							  Set @iPos = 0






                   Select @employeeid = trim(email),  @HerpesBdate = trim([hep B]), @measlesDate = trim(measles), @MumpsDate = trim(Mumps), @RubellaDate = trim(Rubella),
                             @Varicelladate= trim(Varicella),  @Tdapdate = trim(Tdap), @Fullfacerespiratordate = trim([Full Face Respirator]), @StandardRespiratorydate = trim([Standard Respirator]),
                             @Fludate = trim(Flu), @TBSurveillancedate = trim([TB Health Surveillance]), @TBAnnualdate = trim([TB Annual]), @TBWestCampusdate = trim([TB West Campus]),
                             @AIRCMRI_date= trim([AIRC MRI]), @ClinicalMRI_date = trim([Clinical MRI]),
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

				Set @Status = @Status + ' E2 '

                            Update ss
                               Set ss.processed = @Status

                              From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        If @@Error <> 0
	                                GoTo Err_Proc

                                    GOTO Next_Record


                    END  ----


						----Evaluate Hep B data

                     If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Hep B] is not null)
                     BEGIN

                          Select  @HerpesBdate = trim([Hep B]) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Hep B] is not null

                        Set @completiondate = null
                        Set @Temp = ''

  			 If ( @HerpesBdate like 'Complete%')
                         BEGIN

			  set @Temp = right(@HerpesBdate ,len(@HerpesBdate) - (charindex('(', @HerpesBdate) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)

                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END

  			ELSE If ( @HerpesBdate like 'Complete by Declination%')
                         BEGIN

			  set @Temp = right(@HerpesBdate ,len(@HerpesBdate) - (charindex('(', @HerpesBdate ) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END
                        ELSE  if ( @HerpesBdate like 'Incomplete%' )  or ( @HerpesBdate like 'Complete Pending%' )
                           BEGIN
                                  Set @Status = @Status + ' He3  '

                            Update ss
                                 Set ss.processed = @Status

                              From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        If @@Error <> 0
	                                GoTo Err_Proc

					 Set @completiondate = null



			   END
                         ELSE
                          BEGIN
				Set @Status = @Status + ' He3  '

                            Update ss
                               Set ss.processed = @Status

                              From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        If @@Error <> 0
	                                GoTo Err_Proc

				 Set @completiondate = null


                         END

                                         ---- IF all previous version were validated proceed with the record insert

                                                   Set @requirementnameFinal = 'Occupational Health - Hep B Compliant - Level 1'
                                                   Set @comment = @comment + ' OccHealth Import'


					            ----validate if the record already exists

              		 IF exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    		And date = @completiondate)  And @completiondate is not null
               		 BEGIN
							Set @Status = @Status + ' He4 '

                            				Update ss
                               				Set ss.processed = @Status

                              				From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                               				 GoTo Err_Proc


                          END


                          If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    And date = @completiondate)   And @completiondate is not null

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
          			                @requirementnameFinal,
          			                @completiondate,
          			               'OccHealth Import',
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

						Set @Status = @Status + ' He1 '

			   			 Update ss
                               				Set ss.processed =  @Status

                              			From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                                			GoTo Err_Proc


			     END   -----if not exists


                   END  ---If exists





                   If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And measles is not null)
                   BEGIN

                       Select   @measlesDate = trim(measles) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And measles is not null

			 Set @completiondate = null
                         Set @Temp = ''

  			 If ( @measlesDate like 'Complete%')
                         BEGIN
			  set @Temp = right(@measlesDate ,len(@measlesDate) - (charindex('(', @measlesDate) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END

  			ELSE If (@measlesDate like 'Complete by Declination%')
                         BEGIN

			  set @Temp = right(@measlesDate ,len(@measlesDate) - (charindex('(', @measlesDate) + 1))
                         set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END
                        ELSE if ( @measlesDate like 'Incomplete%' )  or ( @measlesDate like 'Complete Pending%' )
                         BEGIN
                               Set @Status = @Status + ' Me3  '

                            Update ss
                               Set ss.processed = @Status

                              From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        If @@Error <> 0
	                                GoTo Err_Proc

 						Set @completiondate = null


			   END
                         ELSE
                          BEGIN
				 Set @Status = @Status + ' Me3  '

                            Update ss
                               Set ss.processed = @Status

                              From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        If @@Error <> 0
	                                GoTo Err_Proc

					 Set @completiondate = null


                         END

                                         ---- IF all previous version were validated proceed with the record insert

                                                   Set @requirementnameFinal = 'Occupational Health - Measles Compliant'
                                                   Set @comment = @comment + ' OccHealth Import'


					            ----validate if the record already exists

              		 IF exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    		And date = @completiondate)  And @completiondate is not null
               		 BEGIN
						 Set @Status = @Status + ' Me4 '
                            				Update ss
                               				Set ss.processed = @Status

                              				From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                               				 GoTo Err_Proc


                          END


                          If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    And date = @completiondate)   And @completiondate is not null

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
          			                @requirementnameFinal,
          			                @completiondate,
          			               'OccHealth Import',
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

						 Set @Status = @Status + ' Me1  '

			   			 Update ss
                               				Set ss.processed = @Status

                              			From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                                			GoTo Err_Proc


			     END   -----if not exists


                   END  ---If exists






                  If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And mumps is not null)
                  BEGIN

                        Select   @MumpsDate = trim(mumps) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And mumps is not null

			 Set @completiondate = null
                         Set @Temp = ''

                    	 If ( @MumpsDate like 'Complete%')
                         BEGIN
                          set @Temp = right(@MumpsDate ,len(@MumpsDate) - (charindex('(', @MumpsDate) + 1))
                          set @Completiondate = left(@Temp,charindex(')', @Temp)- 1)
                         set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END

  			ELSE If (@MumpsDate like 'Complete by Declination%')
                         BEGIN
			  set @Temp = right(@MumpsDate ,len(@MumpsDate) - (charindex('(', @MumpsDate) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END
                        ELSE if (@MumpsDate like 'Incomplete%' )  or (@MumpsDate like 'Complete Pending%' )
                        BEGIN
                                Set @Status = @Status + ' Mu3  '

                            Update ss
                               Set ss.processed = @Status

                              From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        If @@Error <> 0
	                                GoTo Err_Proc

 						Set @completiondate = null

                           END
                         ELSE
                          BEGIN
				 Set @Status = @Status + ' Mu3  '

                            Update ss
                               Set ss.processed = @Status

                              From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        If @@Error <> 0
	                                GoTo Err_Proc

                			Set @completiondate = null

                         END

                                         ---- IF all previous version were validated proceed with the record insert

                                                   Set @requirementnameFinal = 'Occupational Health - Mumps Compliant'
                                                   Set @comment = @comment + ' OccHealth Import'


					            ----validate if the record already exists

              		 IF exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    		And date = @completiondate)  And @completiondate is not null
               		 BEGIN

						       Set @Status = @Status + ' Me4 '

                            				Update ss
                               				Set ss.processed = @Status

                              				From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                               				 GoTo Err_Proc


                          END


                          If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    And date = @completiondate)   And @completiondate is not null

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
          			                @requirementnameFinal,
          			                @completiondate,
          			               'OccHealth Import',
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

						 Set @Status = @Status + ' Mu1 '

			   			 Update ss
                               				Set ss.processed = @Status

                              			From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                                			GoTo Err_Proc


			     END   -----if not exists


                   END  ---If exists






                  If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And Rubella is not null)
                   BEGIN

                          Select  @RubellaDate = trim(Rubella) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And Rubella is not null

			 Set @completiondate = null
                         Set @Temp = ''

                    	 If (@RubellaDate like 'Complete%')
                        BEGIN
			  set @Temp = right(@RubellaDate ,len(@RubellaDate) - (charindex('(', @RubellaDate ) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END

  			ELSE If (@RubellaDate like 'Complete by Declination%')
                         BEGIN
			  set @Temp = right(@RubellaDate ,len(@RubellaDate) - (charindex('(',@RubellaDate) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END
                        ELSE if (@RubellaDate like 'Incomplete%' )  or (@RubellaDate like 'Complete Pending%' )
                           BEGIN
					 Set @Status = @Status + ' Ru3 '

                                              Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
			   END
                         ELSE
                          BEGIN
						 Set @Status = @Status + ' Ru3  '

					    Update ss
                              		 		Set ss.processed = @Status

                             			 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        If @@Error <> 0
	                                GoTo Err_Proc

 						Set @completiondate = null
                         END

                                         ---- IF all previous version were validated proceed with the record insert

                                                   Set @requirementnameFinal = 'Occupational Health - Rubella Compliant'
                                                   Set @comment = @comment + ' OccHealth Import'


					            ----validate if the record already exists

              		 IF exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    		And date = @completiondate)  And @completiondate is not null
               		 BEGIN
						 	Set @Status = @Status + ' Ru4 '

                            				Update ss
                               				Set ss.processed = @Status

                              				From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                               				 GoTo Err_Proc


                          END


                          If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    And date = @completiondate)   And @completiondate is not null

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
          			                @requirementnameFinal,
          			                @completiondate,
          			               'OccHealth Import',
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

						 Set @Status = @Status + ' Ru1 '

			   			 Update ss
                               				Set ss.processed = @Status

                              			From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                                			GoTo Err_Proc


			     END   -----if not exists


                   END  ---If exists



                  If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And  Varicella is not null)
                   BEGIN

                          Select   @Varicelladate =  trim(Varicella) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And  Varicella is not null

			 Set @completiondate = null
                         Set @Temp = ''

                    	 If ( @Varicelladate like 'Complete%')
                         BEGIN
			  set @Temp = right(@Varicelladate ,len(@Varicelladate) - (charindex('(', @Varicelladate ) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END

  			ELSE If ( @Varicelladate like 'Complete by Declination%')
                         BEGIN

			  set @Temp = right(@Varicelladate,len(@Varicelladate) - (charindex('(', @Varicelladate) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END
                        ELSE if (@Varicelladate like 'Incomplete%' )  or (@Varicelladate like 'Complete Pending%' )
                           BEGIN
					 Set @Status = @Status + ' Va3 '

                                                  Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
			   END
                         ELSE
                          BEGIN

					 Set @Status = @Status + ' Va3 '

					 Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
                         END

                                         ---- IF all previous version were validated proceed with the record insert

                                                   Set @requirementnameFinal = 'Occupational Health - Varicella Compliant'
                                                   Set @comment = @comment + ' OccHealth Import'


					            ----validate if the record already exists

              		 IF exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    		And date = @completiondate)  And @completiondate is not null
               		 BEGIN

							 Set @Status = @Status + ' Va4 '

                            				Update ss
                               				Set ss.processed = @Status

                              				From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                               				 GoTo Err_Proc


                          END


                          If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    And date = @completiondate)   And @completiondate is not null

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
          			                @requirementnameFinal,
          			                @completiondate,
          			               'OccHealth Import',
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

						 Set @Status = @Status + ' Va1 '

			   			 Update ss
                               				Set ss.processed = @Status

                              			From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                                			GoTo Err_Proc


			     END   -----if not exists


                   END  ---If exists




                 If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And Tdap  is not null)
                 BEGIN

                          Select  @Tdapdate = trim(Tdap) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And Tdap is not null

			 Set @completiondate = null
                         Set @Temp = ''

		        If (@Tdapdate like 'Complete%')
                         BEGIN
			  set @Temp = right(@Tdapdate ,len(@Tdapdate) - (charindex('(', @Tdapdate) + 1))
                         set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END

  			ELSE If (@Tdapdate like 'Complete by Declination%')
                         BEGIN
			  set @Temp = right(@Tdapdate ,len(@Tdapdate) - (charindex('(', @Tdapdate ) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END
                        ELSE if (@Tdapdate like 'Incomplete%' )  or (@Tdapdate like 'Complete Pending%' )
                          BEGIN
					 Set @Status = @Status + ' Td3 '

                                         Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
			   END
                         ELSE
                          BEGIN
					 Set @Status = @Status + ' Td3 '

					 Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
                         END

                                         ---- IF all previous version were validated proceed with the record insert

                                                   Set @requirementnameFinal = 'Tdap Compliant'
                                                   Set @comment = @comment + ' OccHealth Import'


					            ----validate if the record already exists

              		 IF exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    		And date = @completiondate)  And @completiondate is not null
               		 BEGIN
							 Set @Status = @Status + ' Td4 '

                            				Update ss
                               				Set ss.processed = @Status

                              				From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                               				 GoTo Err_Proc


                          END


                          If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    And date = @completiondate)   And @completiondate is not null

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
          			                @requirementnameFinal,
          			                @completiondate,
          			               'OccHealth Import',
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

 							Set @Status = @Status + ' Td1 '

			   					 Update ss
                               				Set ss.processed = @Status

                              			From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                                			GoTo Err_Proc


			     END   -----if not exists


                   END  ---If exists




                If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Full Face Respirator] is not null  )
                 BEGIN

                          Select  @Fullfacerespiratordate = trim([Full Face Respirator]) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Full Face Respirator] is not null

			 Set @completiondate = null
                         Set @Temp = ''

		        If (@Fullfacerespiratordate like 'Complete%')
                         BEGIN
			  set @Temp = right(@Fullfacerespiratordate ,len(@Fullfacerespiratordate) - (charindex('(', @Fullfacerespiratordate) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END

  			ELSE If (@Fullfacerespiratordate like 'Complete by Declination%')
                         BEGIN
			  set @Temp = right(@Fullfacerespiratordate ,len(@Fullfacerespiratordate) - (charindex('(', @Fullfacerespiratordate) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END
                        ELSE if (@Fullfacerespiratordate like 'Incomplete%' )  or (@Fullfacerespiratordate like 'Complete Pending%' )
                           BEGIN
					 Set @Status = @Status + ' FR3 '

                                       	 Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
			   END
                         ELSE
                          BEGIN
					 Set @Status = @Status + ' FR3 '

					 Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
                         END

                                         ---- IF all previous version were validated proceed with the record insert

                                                   Set @requirementnameFinal = 'Occupational Health - Respiratory Protection - CAPR Training'
                                                   Set @comment = @comment + ' OccHealth Import'


					            ----validate if the record already exists

              		 IF exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    		And date = @completiondate)  And @completiondate is not null
               		 BEGIN
							 Set @Status = @Status + ' FR4 '

                            				Update ss
                               				Set ss.processed = @Status

                              				From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                               				 GoTo Err_Proc


                          END


                          If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    And date = @completiondate)   And @completiondate is not null

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
          			                @requirementnameFinal,
          			                @completiondate,
          			               'OccHealth Import',
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
 							Set @Status = @Status + ' FR1 '

			   			 Update ss
                               				Set ss.processed = @Status

                              			From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                                			GoTo Err_Proc


			     END   -----if not exists


                   END  ---If exists






                If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Standard Respirator] is not null  )
                 BEGIN

                          Select  @StandardRespiratorydate = trim([Standard Respirator]) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Standard Respirator] is not null

			 Set @completiondate = null
                         Set @Temp = ''

		        If (@StandardRespiratorydate like 'Complete%')
                         BEGIN
			  set @Temp = right(@StandardRespiratorydate ,len(@StandardRespiratorydate) - (charindex('(', @StandardRespiratorydate) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END

  			ELSE If (@StandardRespiratorydate like 'Complete by Declination%')
                         BEGIN
			  set @Temp = right(@StandardRespiratorydate ,len(@StandardRespiratorydate) - (charindex('(', @StandardRespiratorydate) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END
                        ELSE if (@StandardRespiratorydate like 'Incomplete%' )  or (@StandardRespiratorydate like 'Complete Pending%' )
                           BEGIN
					 Set @Status = @Status + ' SR3 '

                                       	 Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
			   END
                         ELSE
                          BEGIN

					 Set @Status = @Status + ' SR3 '

					  Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
                         END

                                         ---- IF all previous version were validated proceed with the record insert

                                                   Set @requirementnameFinal = 'Occupational Health - Respiratory Protection - N95 Respirator Fit Testing'
                                                   Set @comment = @comment + ' OccHealth Import'


					            ----validate if the record already exists

              		 IF exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    		And date = @completiondate)  And @completiondate is not null
               		 BEGIN
                            				 Set @Status = @Status + ' SR4 '

							Update ss
                               				Set ss.processed = @Status

                              				From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                               				 GoTo Err_Proc


                          END


                          If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    And date = @completiondate)   And @completiondate is not null

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
          			                @requirementnameFinal,
          			                @completiondate,
          			               'OccHealth Import',
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

						 Set @Status = @Status + ' SR1 '

			   			 Update ss
                               				Set ss.processed = @Status

                              			From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                                			GoTo Err_Proc


			     END   -----if not exists


                   END  ---If exists





	         If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And Flu is not null  )
                 BEGIN

                          Select  @Fludate = trim(Flu) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And Flu is not null

			 Set @completiondate = null
                         Set @Temp = ''

		        If (@Fludate  like 'Complete%')
                         BEGIN
			  set @Temp = right(@Fludate ,len(@Fludate) - (charindex('(', @Fludate) ))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)

                         ---Original date format yyyy-mm-dd   translate to mm-dd-yyyy date format
                          Set @completiondate = cast(@Temp as date)


                        END

  			ELSE If (@Fludate  like 'Complete by Declination%')
                         BEGIN
			  set @Temp = right(@Fludate ,len(@Fludate) - (charindex('(', @Fludate) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END
                        ELSE if (@Fludate  like 'Incomplete%' )  or (@Fludate  like 'Complete Pending%' )
                          BEGIN
					 Set @Status = @Status + ' FU3 '

                                        Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
			   END
                         ELSE
                          BEGIN

	 				Set @Status = @Status + ' FU3 '

					  Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
                         END

                                         ---- IF all previous version were validated proceed with the record insert

                                                   Set @requirementnameFinal = 'Occupational Health - Flu Compliant'
                                                   Set @comment = @comment + ' OccHealth Import'


					            ----validate if the record already exists

              		 IF exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    		And date = @completiondate)  And @completiondate is not null
               		 BEGIN
							 Set @Status = @Status + ' FU4 '

                            				Update ss
                               				Set ss.processed = @Status

                              				From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                               				 GoTo Err_Proc


                          END


                          If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    And date = @completiondate)   And @completiondate is not null

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
          			                @requirementnameFinal,
          			                @completiondate,
          			               'OccHealth Import',
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
						 Set @Status = @Status + ' FU1 '

			   			 Update ss
                               				Set ss.processed = @status

                              			From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                                			GoTo Err_Proc


			     END   -----if not exists


                   END  ---If exists






                 If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [TB Health Surveillance] is not null  )
                 BEGIN

                          Select  @TBSurveillancedate = trim([TB Health Surveillance]) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [TB Health Surveillance] is not null

			 Set @completiondate = null
                         Set @Temp = ''

		        If (@TBSurveillancedate like 'Complete%')
                         BEGIN
			  set @Temp = right( @TBSurveillancedate ,len( @TBSurveillancedate) - (charindex('(',  @TBSurveillancedate) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END

  			ELSE If (@TBSurveillancedate  like 'Complete by Declination%')
                         BEGIN
			  set @Temp = right( @TBSurveillancedate ,len( @TBSurveillancedate) - (charindex('(',  @TBSurveillancedate) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END
                        ELSE if (@TBSurveillancedate like 'Incomplete%' )  or (@TBSurveillancedate like 'Complete Pending%' )
                          BEGIN
					 Set @Status = @Status + ' TS3 '

                                       Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
			   END
                         ELSE
                          BEGIN

 					Set @Status = @Status + ' TS3 '

					 Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
                         END

                                         ---- IF all previous version were validated proceed with the record insert

                                                   Set @requirementnameFinal = 'TB Surveillance Compliant'
                                                   Set @comment = @comment + ' OccHealth Import'


					            ----validate if the record already exists

              		 IF exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    		And date = @completiondate)  And @completiondate is not null
               		 BEGIN
							Set @Status = @Status + ' TS4 '

                            				Update ss
                               				Set ss.processed = @Status

                              				From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                               				 GoTo Err_Proc


                          END


                          If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    And date = @completiondate)   And @completiondate is not null

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
          			                @requirementnameFinal,
          			                @completiondate,
          			               'OccHealth Import',
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

						 Set @Status = @Status + ' TS1 '

			   			 Update ss
                               				Set ss.processed = @Status

                              			From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                                			GoTo Err_Proc


			     END   -----if not exists


                   END  ---If exists



                 If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [TB Annual] is not null  )
                 BEGIN

                          Select  @TBAnnualdate = trim([TB Annual]) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [TB Annual] is not null

			 Set @completiondate = null
                         Set @Temp = ''

		        If (@TBAnnualdate like 'Complete%')
                         BEGIN
			  set @Temp = right(@TBAnnualdate ,len(@TBAnnualdate) - (charindex('(', @TBAnnualdate) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END

  			ELSE If (@TBAnnualdate  like 'Complete by Declination%')
                         BEGIN
			  set @Temp = right(@TBAnnualdate ,len(@TBAnnualdate) - (charindex('(', @TBAnnualdate) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END
                        ELSE if (@TBAnnualdate like 'Incomplete%' )  or (@TBAnnualdate like 'Complete Pending%' )
                         BEGIN
					 Set @Status = @Status + ' TBS3 '

					Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
			   END
                         ELSE
                          BEGIN

					 Set @Status = @Status + ' TBS3 '

					 Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
                         END

                                         ---- IF all previous version were validated proceed with the record insert

                                                   Set @requirementnameFinal = 'TB Compliant - Annual'
                                                   Set @comment = @comment + ' OccHealth Import'


					            ----validate if the record already exists

              		 IF exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    		And date = @completiondate)  And @completiondate is not null
               		 BEGIN

							 Set @Status = @Status + ' TBS4 '

                            				Update ss
                               				Set ss.processed = @Status

                              				From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                               				 GoTo Err_Proc


                          END


                          If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    And date = @completiondate)   And @completiondate is not null

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
          			                @requirementnameFinal,
          			                @completiondate,
          			               'OccHealth Import',
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

						 Set @Status = @Status + ' TBS1 '

			   			 Update ss
                               				Set ss.processed = @Status

                              			From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                                			GoTo Err_Proc


			     END   -----if not exists


                   END  ---If exists






                   If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [TB West Campus] is not null)
                    BEGIN


			 Select @TBWestCampusdate = trim([TB West Campus]) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [TB West Campus] is not null

			 Set @completiondate = null
                         Set @Temp = ''

		        If (@TBWestCampusdate like 'Complete%')
                         BEGIN
			  set @Temp = right(@TBWestCampusdate ,len(@TBWestCampusdate) - (charindex('(', @TBWestCampusdate) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END

  			ELSE If (@TBWestCampusdate  like 'Complete by Declination%')
                         BEGIN
			  set @Temp = right(@TBWestCampusdate ,len(@TBWestCampusdate) - (charindex('(', @TBWestCampusdate) + 1))
                        set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END
                        ELSE if (@TBWestCampusdate like 'Incomplete%' )  or (@TBWestCampusdate like 'Complete Pending%' )
                          BEGIN
					 Set @Status = @Status + ' TBW3 '

                                         Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
			   END
                         ELSE
                          BEGIN
					 Set @Status = @Status + ' TBW3 '

					Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
                         END

                                         ---- IF all previous version were validated proceed with the record insert

                                                   Set @requirementnameFinal = 'Occupational Health - TB Compliant - Initial'
                                                   Set @comment = @comment + ' OccHealth Import'


					            ----validate if the record already exists

              		 IF exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    		And date = @completiondate)  And @completiondate is not null
               		 BEGIN
							 Set @Status = @Status + ' TBW4 '

                            				Update ss
                               				Set ss.processed = @Status

                              				From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                               				 GoTo Err_Proc


                          END


                          If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    And date = @completiondate)   And @completiondate is not null

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
          			                @requirementnameFinal,
          			                @completiondate,
          			               'OccHealth Import',
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

						 Set @Status = @Status + ' TBW1 '

			   			 Update ss
                               				Set ss.processed = @Status

                              			From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                                			GoTo Err_Proc


			     END   -----if not exists


                   END  ---If exists






                 If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [AIRC MRI] is not null)
                  BEGIN

                        Select  @AIRCMRI_date = trim([AIRC MRI]) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [AIRC MRI] is not null

			 Set @completiondate = null
                         Set @Temp = ''

		        If (@AIRCMRI_date like 'Complete%')
                         BEGIN
			  set @Temp = right(@AIRCMRI_date ,len(@AIRCMRI_date) - (charindex('(', @AIRCMRI_date) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END


  			ELSE If (@AIRCMRI_date  like 'Complete by Declination%')
                         BEGIN
			  set @Temp = right( @AIRCMRI_date ,len( @AIRCMRI_date) - (charindex('(',  @AIRCMRI_date) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END
                        ELSE if (@AIRCMRI_date like 'Incomplete%' )  or (@AIRCMRI_date like 'Complete Pending%' )
                           BEGIN

				     Set @Status = @Status + ' AIR3 '

                                      Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
			   END
                         ELSE
                          BEGIN
					 Set @Status = @Status + ' AIR3 '

					Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
                         END

                                         ---- IF all previous version were validated proceed with the record insert

                                                   Set @requirementnameFinal = 'AIRC MRI Compliant'
                                                   Set @comment = @comment + ' OccHealth Import'


					            ----validate if the record already exists

              		 IF exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    		And date = @completiondate)  And @completiondate is not null
               		 BEGIN
							 Set @Status = @Status + ' AIR4 '

                            				Update ss
                               				Set ss.processed = @Status

                              				From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                               				 GoTo Err_Proc


                          END


                          If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    And date = @completiondate)   And @completiondate is not null

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
          			                @requirementnameFinal,
          			                @completiondate,
          			               'OccHealth Import',
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
						 Set @Status = @Status + ' AIR1 '

			   			 Update ss
                               				Set ss.processed = @Status

                              			From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                                			GoTo Err_Proc


			     END   -----if not exists


                   END  ---If exists






                 If exists (Select * from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Clinical MRI] is not null)
                 BEGIN

                          Select  @ClinicalMRI_date = trim([Clinical MRI]) from onprc_ehr_compliancedb.OccHealthTemp where searchID = @Searchkey And [Clinical MRI] is not null

			 Set @completiondate = null
                         Set @Temp = ''

			  If (@ClinicalMRI_date like 'Complete%')
                         BEGIN
			  set @Temp = right(@ClinicalMRI_date ,len(@ClinicalMRI_date) - (charindex('(', @ClinicalMRI_date) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END

  			ELSE If (@ClinicalMRI_date  like 'Complete by Declination%')
                         BEGIN
			  set @Temp = right(@ClinicalMRI_date ,len(@ClinicalMRI_date) - (charindex('(', @ClinicalMRI_date) + 1))
                          set @Temp = left(@Temp,charindex(')', @Temp)- 1)
                          if isdate(@Temp) = 1
                            Set @completiondate = @Temp

                          Set @Temp = ''
                         END
                        ELSE if (@ClinicalMRI_date like 'Incomplete%' )  or (@ClinicalMRI_date like 'Complete Pending%' )
                          BEGIN
				     Set @Status = @Status + ' CLM3 '

                                       Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
			   END
                         ELSE
                          BEGIN

				         Set @Status = @Status + ' CLM3 '

					 Update ss
                              		 Set ss.processed = @Status

                            		 From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                       			 If @@Error <> 0
	                               			 GoTo Err_Proc

 						Set @completiondate = null
                         END

                                         ---- IF all previous version were validated proceed with the record insert

                                                   Set @requirementnameFinal = 'Clinical MRI Compliant'
                                                   Set @comment = @comment + ' OccHealth Import'


					            ----validate if the record already exists

              		 IF exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    		And date = @completiondate)  And @completiondate is not null
               		 BEGIN
							 Set @Status = @Status + ' CLM4 '

                            				Update ss
                               				Set ss.processed = @Status

                              				From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                               				 GoTo Err_Proc


                          END


                          If not exists( Select * from ehr_compliancedb.completiondates Where employeeid = @employeeid And requirementname = @requirementnameFinal
                                    And date = @completiondate)   And @completiondate is not null

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
          			                @requirementnameFinal,
          			                @completiondate,
          			               'OccHealth Import',
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
						 Set @Status = @Status + ' CLM1 '

			   			 Update ss
                               				Set ss.processed = @Status

                              			From onprc_ehr_compliancedb.OccHealth_Data ss  Where ss.rowid = @OccHealthID


      	                        			If @@Error <> 0
	                                			GoTo Err_Proc


			     END   -----if not exists


                   END  ---If exists





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
	        [Email] ,
		[Person Type],
	        [Employee Status],
	        [Total Compliance],
	        [West Campus],
	        [Hep B] ,
	        [Measles],
	        [Mumps],
	        [Rubella],
	        [Varicella],
	        [Tdap],
	        [Full Face Respirator],
	        [Standard Respirator],
	        [Flu],
	        [TB Health Surveillance],
	        [TB Annual],
	        [TB West Campus],
	        [AIRC MRI],
	        [Clinical MRI],
	        [Supervisor Email],
                [trainer],
                [processed],
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

