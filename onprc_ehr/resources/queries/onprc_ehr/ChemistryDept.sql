/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
select value, sort_order  from sla.Reference_Data
where columnName = 'BiochemistryDept'
And endDate is null