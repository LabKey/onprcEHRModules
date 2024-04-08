

/*
**
** 	Created by 		Date
**
**      Blasa  		      4-5-2024  Process to update Environmental Assessment data set  ldk file from Production database.
**
**
**
*/


CREATE Procedure onprc_ehr.p_Environemtal_Update_Process



    AS


BEGIN

    IF exists (Select * from [list].[c8754d723_surface_sanitation_minus_rodac_48hr])
BEGIN


Insert into  onprc_ehr.Environmental_Assessment

(date,
 testing_location,   ----TestSite
 service_requested,
 test_type,     ------TestType
 colony_count,   ---ColonyCount     Before: test_resuls
 pass_fail,      -----PassFail
 performedby,    ------Collectedby
 action,         ----Action
 remarks,       ----comments
 objectid,
 created,
 createdby,
 modified,
 modifiedby,
 qcstate,
 container)

select date,
    TestSite,
    'Sanitation: Contact Plate' ,
    TestType,
    ColonyCount,
    PassFail,
    CollectedBy,
    Action,
    comment,
    newid(),
    getdate(),
    1896,
    getdate(),
    1896,
    18,
    '98F39B23-5E3B-1037-AFE5-BD25D057100A'
from [list].[c8754d723_surface_sanitation_minus_rodac_48hr]



    If @@Error <> 0
    GoTo Err_Proc
END -----



    IF exists (Select * from [list].[c8754d726_h2o_testing])
BEGIN

Insert into  onprc_ehr.Environmental_Assessment

(date,
 testing_location,  ---testing Location
 service_requested,
 water_source,     ----H2OSource,
 test_type,          ----- Testtype
 test_results,          ----result
 pass_fail,             ----PassFail
 remarks,
 objectid,
 created,
 createdby,
 modified,
 modifiedby,
 qcstate,
 container)

select date,
    TestSite,
    'Sanitation: Water Test',
    H2OSource,
    TestType,
    result,
    PassFail,
    comment,
    newid(),
    getdate(),
    1896,
    getdate(),
    1896,
    18,
    '98F39B23-5E3B-1037-AFE5-BD25D057100A'
from [list].[c8754d726_h2o_testing]

    If @@Error <> 0
    GoTo Err_Proc
END -----

     IF exists (Select * from list.c8754d795_biological_indicator_log)
BEGIN

Insert into  onprc_ehr.Environmental_Assessment

(date,
 testing_location,     ---autoclave
 service_requested,
 biological_Cycle,    ----cycle (if applicable)
 biological_BI,     ----BI# (for ASA)
 pass_fail,         ---Pass / Fail
 retest ,   ----Results Read by        Before: test_results
 action,    ----- action
 performedby,       ----collected by
 remarks,
 objectid,
 created,
 createdby,
 modified,
 modifiedby,
 qcstate,
 container)

select date,
    autoclave,
    'Sanitation: Bio-indicator',
    [cycle (if applicable)],
    [BI# (for ASA)],
    [Pass / Fail],
    [Results Read by],
    action,
    [Collected By],
    comment,
    newid(),
    getdate(),
    1896,
    getdate(),
    1896,
    18,
    '98F39B23-5E3B-1037-AFE5-BD25D057100A'

from list.c8754d795_biological_indicator_log

    If @@Error <> 0
    GoTo Err_Proc
END -----


    IF exists (Select * from list.c8754d731_atp_testing)
BEGIN

    ---- Note:  ATP Testing is strictly Kati's entries only


Insert into  onprc_ehr.Environmental_Assessment

(date,
 performedby,         ---tech inititals
 service_requested,
 testing_location,              ----Area
 surface_tested,    --- Surface    column before -->biological_reader
 pass_fail,          --- initial
 remarks,           ---comments
 retest,         ----retest   column before---->water_source
 test_results,        -------Lab/Group
 action	,           -----location
 objectid,
 created,
 createdby,
 modified,
 modifiedby,
 qcstate,
 container)

select    date,
    Tech_Initials,
    'Sanitation: ATP',
    area,
    Surface,
    initial,
    comments,
    retest,
    Lab_Group,
    location,
    newid(),
    getdate(),
    1896,
    getdate(),
    1896,
    18,
    '98F39B23-5E3B-1037-AFE5-BD25D057100A'
from list.c8754d731_atp_testing

    If @@Error <> 0
    GoTo Err_Proc
END -----




RETURN 0


    Err_Proc:
         RETURN 1

END

    GO






/*
**
** 	Created by 		Date
**
**      Blasa  		      4-5-2024  Process to update Environmental Assessment data set  ldk file from Production database.
**
**
**
*/


CREATE Procedure onprc_ehr.p_EnvironemtalHistoricalUpdates



    AS


BEGIN

IF exists (Select * from onprc_ehr.Environmental_Assessment)
BEGIN
---Update Testing location syntax

Update ss
set ss.testing_location = 'COL SW'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Col. SW'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Annex Rm 1',
    ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Annex Rm 1'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL SW',
    ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Colony SW'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Catch Area 2',
    ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Catch 2'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Pens Run 1 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 1'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Pens Run 10 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 10'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Pens Run 11 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 11'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Pens Run 12 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 12'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Pens Run 2 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 2'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Pens Run 3 Lixit'

    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 3'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Pens Run 4 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 4'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Pens Run 5 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 5'


    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Pens Run 6 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 6'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Pens Run 7 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 7'


    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Pens Run 8 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 8'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Pens Run 9 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 9'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 1 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 1'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 10 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 10'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 11 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 11'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 12 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 12'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 13 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 13'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 14 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 14'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 15 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 15'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 16 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 16'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'SGH 17 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 17'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 18 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 18'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 19 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 19'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 2 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 2'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 20 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 20'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 21 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 21'


    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'SGH 22 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 22'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 23 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 23'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'SGH 24 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 24'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 25 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 25'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 26 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 26'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 27 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 27'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 28 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 28'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 29 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 29'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 30 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 30'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 3 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 3'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 31 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 31'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 32 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 32'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 4 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 4'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 5 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 5'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 6 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 6'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 7 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 7'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 8 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 8'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 9 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 9'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'BOS RM 102'

    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Bosky 102'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'BOS RM 103'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Bosky 103'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'BOS RM 104'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Bosky 104'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'BOS RM 122'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Bosky 122'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'BOS RM 123'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Bosky 123'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Cage Washer Colony Annex toy'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Cage Washer Colony Annex tunnel toy'



    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Cage Washer VGTI Large (Jan/June)'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Cage Washer VGTI Large (semi-annual)'


    If @@Error <> 0
    GoTo Err_Proc
Update ss
set ss.testing_location = 'Cage Washer VGTI Small (Jan/June)'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Cage Washer VGTI Small (semi-annual)'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Dishwasher Colony North'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Dishwasher N. Colony'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Dishwasher Colony South'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Dishwasher S. Colony'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Annex Rm 37'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Annex room 37'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Catch Area 2'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Catch 2'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Catch Area 5'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Catch 5'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL SW'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Col. SW'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL NW'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Col. NW'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL NW'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Colony NW'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL RM 4'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Colony RM 4'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL Run 1'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Colony Run 1'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL Run 2'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Colony Run 2'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL Run 3'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Colony Run 3'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL Run 4'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Colony Run 4'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL Run 5'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Colony Run 5'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
      set ss.testing_location = 'COL Run 6'
          -- ss.charge_unit = 'Clinpath'
          from onprc_ehr.Environmental_Assessment ss
      where ss.testing_location = 'Colony Run 6'


                      If @@Error <> 0
                      GoTo Err_Proc
    Update sS
    set ss.testing_location = 'COL Run 7'
            -- ss.charge_unit = 'Clinpath'
            from onprc_ehr.Environmental_Assessment ss
        where ss.testing_location = 'Colony Run 7'


                        If @@Error <> 0
                        GoTo Err_Proc

    Update ss
          set ss.testing_location = 'COL Run 8'
              -- ss.charge_unit = 'Clinpath'
              from onprc_ehr.Environmental_Assessment ss
          where ss.testing_location = 'Colony Run 8'

              If @@Error <> 0
              GoTo Err_Proc


Update ss
set ss.testing_location = 'COL SW'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Colony SW'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 1'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 1  inside'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'SGH 1'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 1 inside'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'SGH 2'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 2  outside'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 2'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 2 outside'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 29'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 29  inside'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 29'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 29 inside'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 30'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 30  outside'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 30'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 30 outside'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Dishwasher Bldg 611 '
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 30 outside'

    If @@Error <> 0
    GoTo Err_Proc

update onprc_ehr.Environmental_Assessment
set testing_location = 'Dishwasher ASA 135'
where testing_location = 'Dishwasher ASA 135 '


    If @@Error <> 0
	    GoTo Err_Proc

update onprc_ehr.Environmental_Assessment
set testing_location = 'Dishwasher ASA 136'
where testing_location = 'Dishwasher ASA 136 '

    If @@Error <> 0
	      GoTo Err_Proc

update onprc_ehr.Environmental_Assessment
set testing_location = 'Dishwasher Bldg 611'
where testing_location = 'Dishwasher Bldg 611 '


    If @@Error <> 0
	      GoTo Err_Proc

Update ss
set ss.testing_location = 'Annex Rm 1'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 1'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Annex Rm 34'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 34'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Annex Rm 13'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 13'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Annex Rm 14'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 14'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Annex Rm 15'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 15'


    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Annex Rm 16'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 16'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Annex Rm 2'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 2'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Annex Rm 34'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 34'


    If @@Error <> 0
    GoTo Err_Proc
Update ss
set ss.testing_location = 'Annex Rm 39'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 39'


    If @@Error <> 0
    GoTo Err_Proc
Update ss
set ss.testing_location = 'Annex Rm 4'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 4'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
      set ss.testing_location = 'Annex Run 1'
          from onprc_ehr.Environmental_Assessment ss
      where ss.testing_location = 'AN RUN 1'


          If @@Error <> 0
          GoTo Err_Proc
Update ss
set ss.testing_location = 'Annex Run 2'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RUN 2'


    If @@Error <> 0
    GoTo Err_Proc
Update ss
set ss.testing_location = 'Annex Run 3'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RUN 3'


    If @@Error <> 0
    GoTo Err_Proc
Update ss
set ss.testing_location = 'Annex Run 30'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RUN 30'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Col Run 7E'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Col Run 7 E'

    If @@Error <> 0
    GoTo Err_Proc

------ Update only locations designated as Clinpath locations.

Update ss
set ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location in (select distinct value from onprc_ehr.Environmental_Reference_Data where columnname = 'testlocation')

    If @@Error <> 0
    GoTo Err_Proc

----------- Update only locations designated as Kati's Room LocationXXXX

update onprc_ehr.Environmental_Assessment
set testing_location = 'Col Run 7A'
where testing_location = 'Col Run 7 A'


    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Col Run 7B'
where testing_location = 'Col Run 7 B'



    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Col Run 7D'
where testing_location = 'Col Run 7 D'



    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Colony Rm 2 (Clinic)'
where testing_location = 'Colony Rm 2 Clinic'



    If @@Error <> 0
	          GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Pens RM 102A  (Clinic)'
where testing_location = 'Pens Rm 102A (Clinic)'



    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Pens RM 104 (Feed)'
where testing_location = 'PENS Rm 104 (Feed Room)'



    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Pens RM 104 (Feed)'
where testing_location = 'Pens RM 104 (Feed )'



    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'VGTI 0120 (clean cage wash)'
where testing_location = 'VGTI 0120 (clean cage wash'



    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Col Run 6A'
where testing_location = 'Col Run 6 A'



    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Col Run 6C'
where testing_location = 'Col Run 6 C'



    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'ASB 3 Cage Wash'
where testing_location = 'ASB 3 Cage Wash Area'



    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'ASB 1 Cage Wash'
where testing_location = 'ASB 1 Cage Wash Area'


    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Cage Washer ASB 1 cage'
where testing_location = 'Cage Washer ASB 1'


    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Cage Washer VGTI Large (Jan/June)'
where testing_location = 'Cage Washer VGTI Large'



    If @@Error <> 0
 	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Cage Washer VGTI Small (Jan/June)'
where testing_location = 'Cage Washer VGTI Small'


    If @@Error <> 0
	                   GoTo Err_Proc

END ----if exists



RETURN 0


    Err_Proc:
         RETURN 1

END

GO



