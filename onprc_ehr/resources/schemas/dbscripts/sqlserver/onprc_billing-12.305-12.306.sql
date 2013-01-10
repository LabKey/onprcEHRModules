DROP TABLE onprc_billing.chargableItems;

CREATE TABLE onprc_billing.chargeableItems (
    rowId INT IDENTITY (1,1) NOT NULL,
    name varchar(200),
    shortName varchar(100),
    category varchar(200),
    comment varchar(4000),
    active bit default 1,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created DATETIME,
    modifiedBy USERID,
    modified DATETIME,

    CONSTRAINT PK_chargeableItems PRIMARY KEY (rowId)
);
