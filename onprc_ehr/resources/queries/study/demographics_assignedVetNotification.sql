/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
--date:  6/19/2019
--Promotoed to UAT by gjones

SELECT
d.id,
d.calculated_Status,
d.earliestRemarkSinceReview,
d.lastVetReview,
v.assignedVet
FROM demographicsAssignedVet v join demographics d on v.id = d.id
where d.lastDayAtCenter > TimestampDiff('SQL_TSI_Day', 90, Now())