/*
 * Copyright (c) 2023-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

select value from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.Reference_Data
where columnname = 'employeehost'
  And enddate is null