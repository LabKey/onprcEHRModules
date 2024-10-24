SELECT
    a.rowId,
    a.subjectId,
    a.analysisId.readset.subjectId as readsetSubjectId,
    a.analysisId,
    a.folder,
    a.analysisId.container

FROM assay.GenotypeAssay.Genotype.Data a
WHERE a.run.assayType = 'SBT' AND a.analysisId.readset.subjectId != a.subjectId
