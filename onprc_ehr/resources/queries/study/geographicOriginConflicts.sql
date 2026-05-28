/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
t.Id,
t.geneticAncestry,
d.geographic_origin

FROM study.demographicsGeneticAncestry t
JOIN study.demographics d on (t.Id = d.Id)
WHERE t.geneticAncestry != d.geographic_origin OR (t.geneticAncestry IS NOT NULL AND d.geographic_origin IS NULL)
