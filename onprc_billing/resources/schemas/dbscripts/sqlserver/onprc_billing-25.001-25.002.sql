-- Contents of onprc_billing25.001-25.002.sql

--cREATED 4/7/2025
--gjones
--NEW Data Set to Select Ciorrect Subsidy for Unit Cost Calculations
--
CREATE TABLE onprc_billing.BaseSubsidyFoundation (
                                                  rowId INT IDENTITY (1,1) NOT NULL,
                                                  Title nvarchar(50)  null,
                                                  BaseSubsidy decimal,
                                                   startDate datetime,
                                                   endDate datetime,

                                                   createdBy integer,
                                                   created datetime,
                                                   modifiedBy integer,
                                                   modified datetime,


);
