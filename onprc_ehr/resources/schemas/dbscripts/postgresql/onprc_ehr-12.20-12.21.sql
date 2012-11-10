CREATE SCHEMA onprc_ehr;

CREATE TABLE onprc_ehr.etl_runs
(
    RowId serial NOT NULL,
    date timestamp,

    Container ENTITYID NOT NULL,

    CONSTRAINT PK_etl_runs PRIMARY KEY (rowId)
);
