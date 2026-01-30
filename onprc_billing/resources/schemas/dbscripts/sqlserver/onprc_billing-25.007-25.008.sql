CREATE TABLE onprc_billing.LeaseIncomeforProject(
                                                    rowId INT IDENTITY(1,1) NOT NULL,
                                                    project INT NOT NULL,
                                                    startDate DATE NOT NULL,
                                                    endDate DATE NULL,
                                                    comment NVARCHAR(4000) NULL,
                                                    CONSTRAINT ProjectLeaseIncome PRIMARY KEY (rowId)
);
