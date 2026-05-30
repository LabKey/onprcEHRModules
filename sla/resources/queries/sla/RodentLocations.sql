/*
 * Copyright (c) 2016-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT room as location, datedisabled
From Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr_lookups.rooms
Where housingtype = 589 and dateDisabled is null