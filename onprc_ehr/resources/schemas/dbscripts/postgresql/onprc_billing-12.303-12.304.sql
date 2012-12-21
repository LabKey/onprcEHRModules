drop table onprc_billing.financialContacts;

CREATE TABLE onprc_billing.fiscalAuthorities (
    rowid serial,
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

    active boolean default true,
    objectid ENTITYID,
    createdBy int,
    created timestamp,
    modifiedBy int,
    modified timestamp,

    CONSTRAINT pk_fiscalAuthorities PRIMARY KEY (rowId)
);