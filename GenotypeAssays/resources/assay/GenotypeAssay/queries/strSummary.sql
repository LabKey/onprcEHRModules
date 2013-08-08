SELECT
  d.subjectId,
  d.category,
  d.marker,
  group_concat(coalesce(CAST(d.result as varchar), d.qual_result), '/') as alleles,
  count(*) as totalResults,
  d.run,

FROM Data d

WHERE d.run.assayType = 'STR' and d.statusflag != 'Exclude'

GROUP BY d.run, d.subjectId, d.marker, d.category