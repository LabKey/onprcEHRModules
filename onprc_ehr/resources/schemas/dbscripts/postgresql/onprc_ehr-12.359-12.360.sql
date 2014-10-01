CREATE TABLE onprc_ehr.birth_condition (
    rowid serial,
    value varchar(200),
    alive boolean,
    description varchar(4000),
    container entityid,
    createdby int,
    created timestamp,
    modifiedby int,
    modified timestamp,

    CONSTRAINT PK_birth_condition PRIMARY KEY (rowid)
);