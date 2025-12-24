CREATE TABLE onprc_billing.ProjectLeaseIncomeEligibility (
                                                             rowId INT IDENTITY(1,1) NOT NULL,
                                                             project INT NOT NULL,
                                                             startDate DATE NOT NULL,
                                                             endDate DATE NULL,
                                                             comment NVARCHAR(4000) NULL,
                                                             CONSTRAINT PK_ProjectLeaseIncomeEligibility PRIMARY KEY (rowId)
);