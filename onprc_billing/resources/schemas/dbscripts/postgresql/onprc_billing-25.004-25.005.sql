-- Contents of onprc_billing25.001-25.002.sql

--cREATED 4/7/2025
--gjones
--NEW Data Set to Select Ciorrect Subsidy for Unit Cost Calculations
--changes name to Indirect
--
CREATE TABLE onprc_billing.IndirectRates (
    rowId SERIAL NOT NULL,
    Title varchar(50) NULL,
    IndirectRate double precision,
    startDate timestamp,
    endDate timestamp,

    createdBy integer,
    created timestamp,
    modifiedBy integer,
    modified timestamp
);
