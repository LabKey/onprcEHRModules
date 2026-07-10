
CREATE TABLE onprc_ehr.Rpt_TempProblemList(
    searchid integer IDENTITY(100,1) NOT NULL,
    animalid varchar(200) NULL,
    date    smalldatetime NULL,
    objectid varchar(4000) NULL,
    caseid    varchar(4000) NULL

    ) ON [PRIMARY]
    GO

CREATE TABLE onprc_ehr.Rpt_TempProblemListMaster(
      searchid integer IDENTITY(100,1) NOT NULL,
      animalid varchar(200) NULL,
      date    smalldatetime NULL,
      objectid varchar(4000) NULL,
      caseid    varchar(4000) NULL

) ON [PRIMARY]
    GO




/*
**
**	 Created by	Date		Comment
**
** 	   blasa     7-7-2026   Process to updated historical problem list records
**
**
**
**/

CREATE  Procedure onprc_ehr.s_MasterProblemHistoricalProcess


AS


declare


    @TempSearchKey     	Int,
    @Searchkey         	Int,
    @AnimalID			varchar(100),
    @date               smalldatetime,
    @objectid           varchar(4000),
    @caseid             varchar(4000)


Begin


    ----- Reset the last two months only

    Delete  onprc_ehr.Rpt_TempProblemList

    If @@Error <> 0
        GoTo Err_Proc



    Set @Tempsearchkey = 0
    Set @Searchkey  = 0
    Set @Animalid = ''
    Set @date = null
    Set @objectid = null
    Set @caseid = null

    --- Set initial processing

    Insert into onprc_ehr.Rpt_TempProblemList
    select  participantid,
            date,
            objectid,
            caseid
    from  studydataset.c6d200_problem
    Where category = 'Wound'
    And subcategory = 'Digit Amputation'
    And qcstate = 18

    Order by participantid

    Select top 1  @SearchKey = searchID from onprc_ehr.Rpt_TempProblemList
    Order by searchid


    While @Tempsearchkey < @SearchKey
        Begin

            Set @Animalid = ''
            Set @date = null
            Set @objectid = null

            select @animalid = animalid, @Date = date, @Objectid = objectid
            from Rpt_TempProblemList Where searchid = @Searchkey

            -------Begin updating records


            Update pb
            Set pb.subcategory = 'Digit Removal/Caudectomy'
            From studydataset.c6d200_problem pb
            Where pb.Participantid = @Animalid
              And pb.objectid = @objectid


            If @@Error <> 0
                GoTo Err_Proc


            Set @TempSearchkey = @Searchkey

            Select Top 1 @SearchKey = searchid From onprc_ehr.Rpt_TempProblemList
            Where searchid > @Tempsearchkey
            Order by searchid




        End ------(While @tempsearchkey < @Searchkey)

        ---- Create an audit record of these entries

          insert into onprc_ehr.Rpt_TempProblemListMaster
              Select animalid, date, objectid, caseid
              from onprc_ehr.Rpt_TempProblemList


    Return 0

    Err_Proc:    Return 1



END




