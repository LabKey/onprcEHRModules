/*
 * Copyright (c) 2022-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
--added to allow department descignation for R & L
EXEC core.fn_dropifexists 'Investigators', 'onprc_ehr', 'COLUMN', 'Department';
GO
ALTER TABLE onprc_ehr.investigators ADD [Department] varchar(250) Null;
