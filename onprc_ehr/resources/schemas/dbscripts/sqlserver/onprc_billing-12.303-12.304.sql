drop table onprc_billing.financialContacts;

CREATE TABLE onprc_billing.fiscalAuthorities (
    rowid int identity(1,1),
    faid varchar(100),
    firstName varchar(100),
    lastName varchar(100),
    position varchar(100),
    address varchar(500),
    city varchar(100),
    state varchar(100),
    country varchar(100),
    zip varchar(100),
    phoneNumber varchar(100),

    active bit default 1,
    objectid ENTITYID,
    createdBy int,
    created datetime,
    modifiedBy int,
    modified datetime,

    CONSTRAINT pk_fiscalAuthorities PRIMARY KEY (rowId)
);