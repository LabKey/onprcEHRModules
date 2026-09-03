select value from ehr_complianceDB.Compliance_Reference_Data
where LOWER(columnName) = 'employeehost'
And endDate is null
