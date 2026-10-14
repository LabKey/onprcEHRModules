/*
 * Copyright (c) 2022-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
select value from ehr_complianceDB.Compliance_Reference_Data
where columnName = 'employeeHost'
And endDate is null
