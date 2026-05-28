/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
ALTER TABLE onprc_ehr.AvailableBloodVolume ALTER COLUMN Id nvarchar(32) NOT NULL;
GO

ALTER TABLE onprc_ehr.AvailableBloodVolume ADD CONSTRAINT PK_AvailableBloodVolume PRIMARY KEY (Id);
GO
