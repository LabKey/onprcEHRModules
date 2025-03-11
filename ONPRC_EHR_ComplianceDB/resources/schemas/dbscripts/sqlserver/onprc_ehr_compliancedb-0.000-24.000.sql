
CREATE SCHEMA onprc_ehr_compliancedb;
GO

CREATE TABLE onprc_ehr_compliancedb.SciShield_Data
(
    RowId INT IDENTITY(1,1) NOT NULL,
    employeeId nvarchar(255) not null,
    requirementname nvarchar(255) null,
    Date datetime null,
    Container ENTITYID NOT NULL,
    comment nvarchar(2000) null,
    CreatedBy USERID,
    Created datetime,
    ModifiedBy USERID,
    Modified datetime,
    processed int NULL

    CONSTRAINT PK_ScieShield_Data PRIMARY KEY (RowId),
    CONSTRAINT FK_ONPRC_EHR_COMPLIANCE_SCISHIELD_DATA_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
CREATE INDEX IX_ONPRC_EHR_COMPLIANCEDB_SCISHIELD_DATA_CONTAINER ON onprc_ehr_compliancedb.SciShield_Data (Container);

CREATE TABLE onprc_ehr_compliancedb.SciShield_Reference_Data
(
    rowId int identity(1,1),
    label nvarchar(250) NULL,
    value nvarchar(255) NOT NULL ,
    columnName nvarchar(255)  NOT NULL,
    sort_order integer  null,
    endDate  datetime  NULL,
    Container ENTITYID NOT NULL,
    CreatedBy USERID,
    Created datetime,
    ModifiedBy USERID,
    Modified datetime,

    CONSTRAINT pk_SciShield_reference PRIMARY KEY (value),
    CONSTRAINT FK_ONPRC_EHR_COMPLIANCE_REFERENCE_DATA_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
CREATE INDEX IX_ONPRC_EHR_COMPLIANCEDB_SCISHIELD_REFERENCE_DATA_CONTAINER ON onprc_ehr_compliancedb.SciShield_Reference_Data (Container);

GO