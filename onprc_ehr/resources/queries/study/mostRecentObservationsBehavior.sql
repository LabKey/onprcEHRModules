/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

--- Created: 8-23-2018  R.Blasa
-- Converted to a left join to allow cases to appear even though the most recent observation is linked to
-- another animal's case. See EHR Issue 12144: Behavior cases not showing.
SELECT
    c.Id,
    c.date,
    c.reviewDate,
    c.isActive,
    c.allProblemCategories,
    c.caseHistory,
    c.isOpen,
    c.objectId,
    o.observations
FROM study.cases AS c
LEFT JOIN study.mostRecentObservationsForCase AS o
    ON c.Id = o.Id
    AND c.objectId = o.caseId
WHERE c.category = 'Behavior'
