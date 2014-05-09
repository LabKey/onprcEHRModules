SELECT
  d.subjectId,
  d.category,
  d.marker,
  d.ref_nt_name,
  d.position,
  group_concat(distinct coalesce(CAST(d.nt as varchar), 'ND'), '/') as alleles,
  count(*) as totalResults

FROM Data d

WHERE (d.statusflag != 'Exclude' or d.statusflag IS NULL)

GROUP BY d.subjectId, d.marker, d.ref_nt_name, d.position, d.category