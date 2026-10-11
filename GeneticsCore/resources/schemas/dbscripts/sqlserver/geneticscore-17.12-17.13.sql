/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
ALTER TABLE geneticscore.mhc_data DROP CONSTRAINT PK_mhc_data;
ALTER TABLE geneticscore.mhc_data ALTER COLUMN objectid entityid NOT NULL;
GO
ALTER TABLE geneticscore.mhc_data ADD CONSTRAINT PK_mhc_data PRIMARY KEY (objectid);