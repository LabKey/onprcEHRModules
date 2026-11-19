/*
 * Copyright (c) 2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
-- Created by Kolli, March 2026
--New query created in the code base as the automated tests are failing.
SELECT s.Id,
       s.date,
       s.set_number,
       s.code,
       s.qualifier
FROM ehr.snomed_tags s
where s.code like 'P-YY961'

Union

SELECT s.Id,
       s.date,
       s.set_number,
       s.code,
       s.qualifier
FROM ehr.snomed_tags s
where s.code like 'P-YY960'