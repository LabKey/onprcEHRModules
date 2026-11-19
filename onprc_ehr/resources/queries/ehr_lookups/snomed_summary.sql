/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
    s.code,
    s.meaning,
    sc.primaryCategory,
    s.container
FROM ehr_lookups.snomed s
LEFT JOIN ehr_lookups.snomed_subset_codes sc ON s.code = sc.code