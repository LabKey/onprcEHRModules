/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT value, name, sort_order from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.StudyDetails_Reference_Data
where name like 'Study_Cohort' and dateDisabled is null