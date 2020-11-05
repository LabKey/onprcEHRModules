/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

-- Dev machines on release20.7-SNAPSHOT would be on module v. 18.10, and will already have below run as part of onprc_ehr-17.20-17.21.sql, and won't be needing this script to run
-- Onprc devs/server will be getting upgraded from svn onprc19.1Prod, which is already on module v. 20.417, so won't be needing this script to run
-- Below is now part of rolled up script onprc_ehr-0.00-18.10.sql for bootstrapped database
-- Commenting it out instead of deleting this file in order to preserve script numbering continuity

--Add container column
-- ALTER TABLE onprc_ehr.observation_types ADD container entityid;
-- GO
--
-- --Add container ids to onprc_ehr.observation_types:
-- UPDATE onprc_ehr.observation_types
-- SET container = (SELECT c.entityid FROM core.containers c
--                  LEFT JOIN core.Containers c2 ON c.Parent = c2.EntityId
--                  WHERE c.name = 'EHR' and c2.name = 'ONPRC')
-- WHERE container IS NULL;
-- GO
--
-- --copy data into ehr table
-- INSERT INTO ehr.observation_types
-- (value,
-- category,
-- editorconfig,
-- schemaName,
-- queryName,
-- valueColumn,
-- createdby,
-- created,
-- modifiedby,
-- modified,
-- container
-- )
-- SELECT
--   value,
--   category,
--   editorconfig,
--   schemaName,
--   queryName,
--   valueColumn,
--   createdby,
--   created,
--   modifiedby,
--   modified,
--   container
-- FROM onprc_ehr.observation_types obs
-- WHERE obs.container IS NOT NULL;
-- GO
--
-- --drop table
-- DROP TABLE onprc_ehr.observation_types
-- GO