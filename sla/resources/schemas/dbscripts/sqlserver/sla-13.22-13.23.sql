/*
 * Copyright (c) 2014-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
ALTER TABLE sla.census DROP CONSTRAINT PK_Census;
GO
ALTER TABLE sla.census ALTER COLUMN objectid ENTITYID NOT NULL;
GO
ALTER TABLE sla.census DROP COLUMN rowid;

ALTER TABLE sla.census ADD CONSTRAINT PK_Census PRIMARY KEY (objectid);