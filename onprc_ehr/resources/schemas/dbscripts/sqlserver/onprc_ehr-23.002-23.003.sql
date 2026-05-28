/*
 * Copyright (c) 2022-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

-- Created: 10-10-2022  R. Blasa to correct type definitionss


ALTER TABLE onprc_ehr.encounter_summaries_remarks ALTER COLUMN createdby userid;
GO


ALTER TABLE onprc_ehr.encounter_summaries_remarks ALTER COLUMN modifiedby userid;
GO