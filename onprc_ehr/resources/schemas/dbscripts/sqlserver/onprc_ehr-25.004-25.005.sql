/*
 * Copyright (c) 2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

CREATE TABLE onprc_ehr.Rpt_TempJmacDate(
    searchid integer IDENTITY(100,1) NOT NULL,
    animalid varchar(200) NULL,
    JBGRemovalDate smalldatetime NULL,
    JBGActualRemovalDate smalldatetime NULL

    ) ON [PRIMARY]
    GO

CREATE TABLE onprc_ehr.JmacRemovalDate(
    searchid integer IDENTITY(100,1) NOT NULL,
    Id varchar(100) NULL,
    JBGRemovalDate smalldatetime NULL,
    JBGActualRemovalDate smalldatetime NULL,
    DaysDiff float NULL,
    reason varchar(100) NULL
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
    @AnimalID			varchar(100),
    @OrgRemovalDate  smalldatetime,
    @ActualRemovalDate smalldatetime


Begin


    ----- Reset the last two months only

    Delete  onprc_ehr.Rpt_TempJmacDate

    If @@Error <> 0
        GoTo Err_Proc



    Set @Tempsearchkey = 0
    Set @Searchkey  = 0
    Set @Animalid = ''
    Set @OrgRemovalDate = null
    Set @ActualRemovalDate = null

    --- Set initial processing

    Insert into onprc_ehr.Rpt_TempJmacDate
    select Id, JBGRemovalDate, JBGActualRemovalDate
    from onprc_ehr.JmacRemovalDate

    Order by searchid

    Select top 1  @SearchKey = searchID from onprc_ehr.Rpt_TempJmacDate
    Order by searchid


    While @Tempsearchkey < @SearchKey
        Begin

            Set @Animalid = ''
            Set @OrgRemovalDate = null
            Set @ActualRemovalDate = null

            select @animalid = animalid, @OrgRemovalDate = JBGRemovalDate, @ActualRemovalDate = JBGActualRemovalDate
            from onprc_ehr.Rpt_TempJmacDate Where searchid = @Searchkey

            -------Begin updating records


            Update JB
            Set JB.enddate = @ActualRemovalDate
            From StudyDataset.c6d346_animal_group_members JB
            Where JB.Participantid = @Animalid
              And cast(JB.enddate as Date) = cast(@OrgRemovalDate as Date)


            If @@Error <> 0
                GoTo Err_Proc


            Set @TempSearchkey = @Searchkey

            Select Top 1 @SearchKey = searchid From onprc_ehr.Rpt_TempJmacDate
            Where searchid > @Tempsearchkey
            Order by searchid




        End ------(While @tempsearchkey < @Searchkey)


    Return 0

    Err_Proc:    Return 1




END




