
CREATE TABLE onprc_ehr.Rpt_TempJmacDate(
    searchid integer IDENTITY(100,1) NOT NULL,
    animalid varchar(200) NULL,
    JBGRemovalDate varchar(255) NULL,
    JBGActualRemovalDate varchar(255) NULL

    ) ON [PRIMARY]
    GO



/*
**
**	 Created by	Date		Comment
**
** 	   blasa     4/10/2026    Process to update jmac Removal date
**
**
**
**/

CREATE  Procedure onprc_ehr.s_JmacRemovalDateProcess


AS


declare


    @TempSearchKey     	Int,
    @Searchkey         	Int,
    @AnimalID			Int











Begin





    ----- Reset the last two months only

    Delete  onprc_ehr.Rpt_TempJmacDate

    If @@Error <> 0
        GoTo Err_Proc



    Set @Tempsearchkey = 0
    Set @Searchkey  = 0

    --- Set initial processing

    Insert into onprc_ehr.Rpt_TempJmacDate
    select * from JmacRemovalDate
    Order by ID

    Select top 1  @SearchKey = searchID from onprc_ehr.Rpt_TempJmacDate
    Order by searchid


    While @Tempsearchkey < @SearchKey
        Begin



            select @animalid = Id, @OrgRemovalDate = JBGRemovalDate, @ActualRemovalDate = JBGActualRemovalDate
            from onprc_ehr.Rpt_TempJmacDate Where searchid = @Searchkey

            -------Begin updating records


            Update JB
            Set JB.enddate = @ActualRemovalDate
            From Study.AnimalGroups JB
            Where JB.Participantid = @Animalid
              And cast(JB.enddate as Date) = cast(@OrgRemovalDate as Date)


            If @@Error <> 0
                GoTo Err_Proc




            Set @TempSearchkey = @Searchkey

            Select Top 1 @SearchKey = searchid From onprc_ehr.Rpt_TempJmacDatet
            Where @Searchkey > @Tempsearchkey
            Order by searchid




        End ------(While @tempsearchkey < @Searchkey)





End ----- (While)




    Return 0

    Err_Proc:    Return 1




END




