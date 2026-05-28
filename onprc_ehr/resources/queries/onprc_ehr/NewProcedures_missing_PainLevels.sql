/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
-- This query extracts the active procedures that were created newly with missing USDA pain categories.
-- Set the date range to 1 year back from curr date
Select
    Name as ProcedureName,
    PainCategories as USDAPainCategories,
    Category,
    major as IsMajor,
    Active
From ehr_lookups.procedures
Where active = 'true'
  And PainCategories IS NULL
