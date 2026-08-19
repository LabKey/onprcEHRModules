select value from ehr_complianceDB.Compliance_Reference_Data
where LOWER(columnName) = LOWER('employeeHost')
And endDate is null
