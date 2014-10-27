CREATE TABLE onprc_ehr.observation_types (
    value varchar(200),
    category varchar(200),
    editorconfig varchar(4000),
    schemaname varchar(200),
    queryname varchar(200),
    valuecolumn varchar(200),
    createdby int,
    created timestamp,
    modifiedby int,
    modified timestamp,

    CONSTRAINT PK_observation_types PRIMARY KEY (value)
);