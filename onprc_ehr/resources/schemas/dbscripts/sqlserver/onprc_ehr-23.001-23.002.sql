CREATE TABLE [onprc_ehr].[Environmental_Assessment](
    rowid int IDENTITY(100,1) NOT NULL,
    date datetime NULL,
    service_requested nvarchar(300) NULL,
    testing_location nvarchar(300) NULL,
    test_type nvarchar(300) NULL,
    test_results nvarchar(100) NULL,
    pass_fail nvarchar(100) NULL,
    testing_equipment nvarchar(300) NULL,
    biological_Cycle nvarchar(300) NULL,
    colony_count int NULL,
    action nvarchar(300) NULL,
    performedby nvarchar(1000) NULL,
    remarks nvarchar(500) NULL,
    water_source nvarchar(300) NULL,
    surface_tested nvarchar(300) NULL,
    retest nvarchar(300) NULL,
    objectid ENTITYID Not Null,
    createdby int NULL,
    created datetime NULL,
    modifiedby int NULL,
    modified datetime NULL,
    container ENTITYID,
    taskid nvarchar(4000) NULL,
    qcstate int NULL,
    formsort int NULL



    CONSTRAINT PK_assessment PRIMARY KEY (objectid)

    )
    GO