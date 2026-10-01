/*
 * Copyright (c) 2014-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

WITH assignmentData AS (
    SELECT DISTINCT
        Id,
        Area,
        Room,
        CASE
            WHEN AssignmentType = 'Open Case' THEN (AssignedVet || ', Open Case: ' || COALESCE(MasterProblems, ''))
            ELSE (AssignedVet || ', ' || AssignmentType)
            END AS assignment
    FROM demographicsAssignedVet
)
SELECT
    Id,
    Area,
    Room,
    GROUP_CONCAT(assignment, chr(10)) AS Vets
FROM assignmentData
GROUP BY Id, Area, Room
HAVING COUNT(*) > 1
