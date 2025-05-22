-- Contents of onprc_billing25.001-25.002.sql

--cREATED 4/7/2025
--gjones
--NEW Data Set to Select Ciorrect Subsidy for Unit Cost Calculations
--changes name to Indirect
--
CREATE TABLE onprc_billing.IndirectRates (
                                             rowId INT IDENTITY (1,1) NOT NULL,
                                             Title nvarchar(50)  null,
                                             IndirectRate float,
                                             startDate datetime,
                                             endDate datetime,

                                             createdBy integer,
                                             created datetime,
                                             modifiedBy integer,
                                             modified datetime,


);
