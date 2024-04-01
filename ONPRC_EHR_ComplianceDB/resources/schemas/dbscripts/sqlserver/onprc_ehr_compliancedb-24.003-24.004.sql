



-- Author:	R. Blasa
-- Created: 4-1-2024  Compliance Procedure Recent test reporting



CREATE TABLE onprc_ehr_compliancedb.ProcedureRecentTests_report (
    rowid                      int IDENTITY(1,1) NOT NULL,
    email                      varchar(350) null,
    employeeid                 varchar(350) null,
    lastname                   varchar(255) null,
    firstname                  varchar(255) null,
    host                       varchar(255) null,
    unit                       varchar  (500) NULL,
    category                   varchar (500) NULL,
    requirementname            varchar (500) NULL,
    trackingflag               varchar](100) NULL,
    times_completed            datetime NULL,
    expired_period             int NULL,
    new_expired_period         int NULL,
    mostrecentdate             datetime  NULL,
    comment                   varchar(2000) NULL,
    months_until_renewal      float NULL,
    snooze_date               datetime NULL,
    Container ENTITYID NOT NULL,
    CreatedBy USERID,
    Created datetime,
    ModifiedBy USERID,
    Modified datetime


    CONSTRAINT PK_Compliance_Report PRIMARY KEY (rowid),
    ) ;
    GO





