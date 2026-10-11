/*
 * Copyright (c) 2014-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
    m.subjectId as Id,
    true as hasSBTData

FROM geneticscore.mhc_data m
