
EXEC core.fn_dropifexists 'Environmental_Assessment', 'onprc_ehr', 'TABLE', NULL;
GO

CREATE TABLE onprc_ehr.Environmental_Assessment(
        rowid int IDENTITY(100,1) NOT NULL,
        date datetime NULL,
        service_requested varchar(300) NULL,
        charge_unit varchar(300) NULL,
        testing_location  varchar(300) NULL,
        test_type  varchar(300) NULL,
        test_results  varchar(100) NULL,
        pass_fail  varchar(100) NULL,
        biological_Cycle  varchar(300) NULL,
        biological_BI  varchar(300) NULL,
        action  varchar(300) NULL,
        performedby  varchar(1000) NULL,
        remarks  varchar(500) NULL,
        water_source  varchar(300) NULL,
        surface_tested  varchar(300) NULL,
        retest  varchar(300) NULL,
        colony_count  varchar(300) NULL,
        test_method  varchar(500) NULL,
        objectid ENTITYID Not Null,
        createdby int NULL,
        created datetime NULL,
        modifiedby int NULL,
        modified datetime NULL,
        Container ENTITYID NOT NULL,
        taskid  entityid,
        qcstate int NULL,
        formsort int NULL


        CONSTRAINT PK_assessment PRIMARY KEY (objectid)
)

    GO