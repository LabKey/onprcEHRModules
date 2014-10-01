CREATE TABLE onprc_ehr.birth_condition (
    rowid int identity(1,1),
    value varchar(200),
    alive bit,
    description varchar(4000),
    container entityid,
    createdby int,
    created datetime,
    modifiedby int,
    modified datetime,

    CONSTRAINT PK_birth_condition PRIMARY KEY (rowid)
);