/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT m.MissingItem,
Count(m.Item) As TotalMissing
--m.Vet_AssignedItem,
--m.totalNHps
FROM vet_assignmentMissingData m
group by m.missingItem