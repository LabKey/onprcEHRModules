SELECT
  d.subjectId,
  d.category,
  d.marker,
  group_concat(distinct coalesce(CAST(d.result as varchar), 'ND'), '/') as alleles,
  count(*) as totalResults,
  d.run,

FROM Data d

WHERE d.run.assayType = 'STR' and (d.statusflag != 'Exclude' or d.statusflag IS NULL)

GROUP BY d.run, d.subjectId, d.marker, d.category