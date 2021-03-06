-- This is the source query for aggregating MHC data into geneticscore.mhc_data
SELECT t.subjectId, t.allele as marker, t.result, GROUP_CONCAT(distinct t.assaytype) as assaytype, sum(totalTests) as totalTests

FROM (
  SELECT
    s.subjectId,
    s.allele,
    --s.primerPairs,
    s.shortName,
    s.totalRecords as totalTests,
    s.status as result,
    cast('SSP' as varchar) as assaytype

  FROM assay.SSP_assay.SSP.SSP_Summary s
  WHERE s.subjectId is not null

  UNION ALL

  SELECT
    a.subjectId,
    a.marker as allele,
    null as shortName,
    count(*) as totalTests,
    cast('POS' as varchar) as result,
    cast('SBT' as varchar) as assaytype

  FROM assay.GenotypeAssay.Genotype.Data a
  WHERE a.run.assayType = 'SBT'
  GROUP BY a.subjectid, a.marker

  UNION ALL

  SELECT
    DISTINCT s.subjectId,
             p.ref_nt_name as allele,
             null as shortName,
             1 as totalTests,
             cast('NEG' as varchar) as result,
             cast('SBT' as varchar) as assaytype

   --we want any IDs with SBT data, but lacking data for these special-cased markers
  FROM genotypeassays.primer_pairs p
         FULL JOIN (SELECT DISTINCT subjectId FROM assay.GenotypeAssay.Genotype.Data s WHERE s.run.assayType = 'SBT') s ON (1=1)
         LEFT JOIN assay.GenotypeAssay.Genotype.Data a ON (a.run.assayType = 'SBT' AND p.ref_nt_name = a.marker AND a.subjectid = s.subjectid)
  WHERE a.rowid IS NULL AND (p.ref_nt_name LIKE 'Mamu-A%' OR p.ref_nt_name LIKE 'Mamu-B%')

  ) t

GROUP BY t.subjectId, t.allele, t.result