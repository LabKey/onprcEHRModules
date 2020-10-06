-- Created: 4-26-2017  R.Blasa

CREATE TABLE onprc_billing.MergeChargtypeUpdates (
    rowid int IDENTITY(1,1) NOT NULL,
    ProjectName varchar(50) not null,
    Protocol varchar(100) not null,
    ChargeType varchar(50) not null,
    objectid ENTITYID,
    startDate datetime,
    endDate datetime

CONSTRAINT PK_MergeType PRIMARY KEY(rowid)
);