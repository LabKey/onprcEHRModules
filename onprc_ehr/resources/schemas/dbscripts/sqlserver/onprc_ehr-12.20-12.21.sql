CREATE SCHEMA onprc_ehr;
GO
CREATE TABLE onprc_ehr.etl_runs
(
    RowId int identity(1,1),
    date datetime,

    Container ENTITYID NOT NULL,

    CONSTRAINT PK_etl_runs PRIMARY KEY (rowId)
);
