-- Contents of onprc_billing25.001-25.002.sql

--cREATED 4/7/2025
--gjones
--NEW Data Set to Select Ciorrect Subsidy for Unit Cost Calculations
--changes name to Indirect
--

CREATE TABLE onprc_billing.LeaseIncomeforProject(
                                                             rowId INT IDENTITY(1,1) NOT NULL,
                                                             project INT NOT NULL,
                                                             startDate DATE NOT NULL,
                                                             endDate DATE NULL,
                                                             comment NVARCHAR(4000) NULL,
                                                             CONSTRAINT ProjectLeaseIncome PRIMARY KEY (rowId)
);
