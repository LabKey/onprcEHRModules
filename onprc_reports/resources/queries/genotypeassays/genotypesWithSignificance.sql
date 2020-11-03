SELECT
d.subjectId as Id,
d.date,
t.label,
t.comment

FROM assay.SSP_Assay.TaqMan.data d
JOIN geneticscore.test_significance t ON (d.primerPair = t.probe AND d.result = t.genotype)