/*
 * Copyright (c) 2024-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Select value
from onprc_ehr.Environmental_Reference_Data
Where ColumnName in ('testLocation', 'testAtpLocation')
order by value
