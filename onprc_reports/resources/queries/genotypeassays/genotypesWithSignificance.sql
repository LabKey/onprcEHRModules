/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
d.subjectId as Id,
d.date,
t.label,
t.comment

FROM assay.SSP_Assay.TaqMan.data d
JOIN geneticscore.test_significance t ON (d.primerPair = t.probe AND d.result = t.genotype)