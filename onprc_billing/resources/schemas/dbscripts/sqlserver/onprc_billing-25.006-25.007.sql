

--cREATED 1/27/2026
--gjones
--New Dataset to hold Projects that can receive LEase Fee Revenue
--changes name to Lease Income For Project
-- permissions restricted to ISE and Sally
--

CREATE TABLE onprc_billing.LeaseIncomeforProject(
                                                    rowId INT IDENTITY(1,1) NOT NULL,
                                                    project INT NOT NULL,
                                                    startDate DATE NOT NULL,
                                                    endDate DATE NULL,
                                                    comment NVARCHAR(4000) NULL,
                                                    CONSTRAINT ProjectLeaseIncome PRIMARY KEY (rowId)
);
