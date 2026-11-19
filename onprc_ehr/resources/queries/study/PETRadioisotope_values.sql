/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT value, columnname from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.reference_data where  columnname like 'PETRadioisotope'