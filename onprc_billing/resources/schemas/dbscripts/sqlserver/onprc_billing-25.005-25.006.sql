/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
--This update allows the endDate field to be NULL
--Revised 2025-06-30
ALTER TABLE onprc_billing.IndirectRates
ALTER COLUMN EndDate DATETIME NULL;
