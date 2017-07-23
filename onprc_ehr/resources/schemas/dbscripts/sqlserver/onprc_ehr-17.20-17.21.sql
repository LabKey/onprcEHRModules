/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

--Add container column
ALTER TABLE onprc_ehr.observation_types ADD container entityid;
GO

--Add container ids to onprc_ehr.observation_types:
UPDATE onprc_ehr.observation_types
SET container = (SELECT c.entityid FROM core.containers c
                 LEFT JOIN core.Containers c2 ON c.Parent = c2.EntityId
                 WHERE c.name = 'EHR' and c2.name = 'ONPRC')
WHERE container IS NULL;
GO

--copy data into ehr table
INSERT INTO ehr.observation_types
(value,
category,
editorconfig,
schemaName,
queryName,
valueColumn,
createdby,
created,
modifiedby,
modified,
container
)
SELECT
  value,
  category,
  editorconfig,
  schemaName,
  queryName,
  valueColumn,
  createdby,
  created,
  modifiedby,
  modified,
  container
FROM onprc_ehr.observation_types obs
WHERE obs.container IS NOT NULL;
GO

--drop table
DROP TABLE onprc_ehr.observation_types
GO