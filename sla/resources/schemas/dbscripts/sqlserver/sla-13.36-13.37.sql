/*
 * Copyright (c) 2017-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
ALTER TABLE sla.purchaseDetails add sla_DOB DATETIME;
ALTER TABLE sla.purchaseDetails add vendorLocation VARCHAR(200);