/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
-- This is the source query for aggregating MHC data into geneticscore.mhc_data

SELECT
    s.subjectId,
    s.allele as marker,
    --s.primerPairs,
    s.shortName,
    s.totalRecords as totalTests,
    s.status as result,
    cast('SSP' as varchar) as assaytype,
    'N/A' as librarytype,
    NULL as score,
    s.modified,
    null as analysisId

FROM assay.SSP_assay.SSP.SSP_Summary s
WHERE s.subjectId is not null

UNION ALL

SELECT
    a.subjectId,
    a.marker,
    null as shortName,
    count(*) as totalTests,
    group_concat(distinct a.qual_result, ',') as result,
    cast('SBT' as varchar) as assaytype,
    group_concat(DISTINCT a.analysisId.readset.libraryType, ',') as librarytype,
    AVG(a.result) AS score,
    greatest(max(a.modified), max(a.analysisId.readset.modified)) as modified,
    a.analysisId

FROM assay.GenotypeAssay.Genotype.Data a
WHERE a.run.assayType = 'SBT' AND a.analysisId.readset.libraryType LIKE 'SBT_MHC_Class_I!_%' ESCAPE '!'
GROUP BY a.subjectid, a.marker, a.analysisId

UNION ALL

SELECT
DISTINCT s.subjectId,
         p.ref_nt_name as marker,
         null as shortName,
         1 as totalTests,
         cast('NEG' as varchar) as result,
         cast('SBT' as varchar) as assaytype,
         null as librarytype,
         NULL as score,
         greatest(s.modified, s.rsModified) as modified,
         s.analysisId

--we want any IDs with SBT data, but lacking data for these special-cased markers
FROM genotypeassays.primer_pairs p
     -- NOTE: this is now grouped on analysisId, so that we report one record for each unit of data, rather than one for each subject as a whole:
     FULL JOIN (
        SELECT
            subjectId,
            s.analysisId,
            max(s.modified) as modified,
            max(s.analysisId.readset.modified) as rsModified
        FROM assay.GenotypeAssay.Genotype.Data s
        WHERE s.subjectId IS NOT NULL AND s.run.assayType = 'SBT' AND s.analysisId.readset.libraryType LIKE 'SBT_MHC_Class_I!_%' ESCAPE '!'
        GROUP BY s.subjectId, s.analysisId
     ) s ON (1=1)
     LEFT JOIN assay.GenotypeAssay.Genotype.Data a ON (
         a.run.assayType = 'SBT' AND
         p.ref_nt_name = a.marker AND
         a.subjectid = s.subjectid AND
         a.analysisId = s.analysisId AND
         s.analysisId.readset.libraryType LIKE 'SBT_MHC_Class_I!_%' ESCAPE '!'
     )
WHERE a.rowid IS NULL AND s.subjectId IS NOT NULL AND (p.ref_nt_name LIKE 'Mamu-A%' OR p.ref_nt_name LIKE 'Mamu-B%')
