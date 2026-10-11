/*
 * Copyright (c) 2024-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
    a.rowId,
    a.subjectId,
    a.analysisId.readset.subjectId as readsetSubjectId,
    a.analysisId,
    a.folder,
    a.analysisId.container

FROM assay.GenotypeAssay.Genotype.Data a
WHERE a.run.assayType = 'SBT' AND a.analysisId.readset.subjectId != a.subjectId
