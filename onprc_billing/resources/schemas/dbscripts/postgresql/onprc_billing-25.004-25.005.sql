
CREATE TABLE onprc_billing.IndirectRates (
    rowId SERIAL,
    Title varchar(50) NULL,
    IndirectRate double precision,
    startDate TIMESTAMP,
    endDate TIMESTAMP,

    createdBy integer,
    created TIMESTAMP,
    modifiedBy integer,
    modified TIMESTAMP,

    CONSTRAINT PK_IndirectRates PRIMARY KEY (rowId) -- Note: no PK on SQL Server
);
