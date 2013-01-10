DROP TABLE onprc_billing.chargableItems;

CREATE TABLE onprc_billing.chargeableItems (
    rowId SERIAL NOT NULL,
    name varchar(200),
    shortName varchar(100),
    category varchar(200),
    comment varchar(4000),
    active boolean default true,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created timestamp,
    modifiedBy USERID,
    modified timestamp,

    CONSTRAINT PK_chargeableItems PRIMARY KEY (rowId)
);
