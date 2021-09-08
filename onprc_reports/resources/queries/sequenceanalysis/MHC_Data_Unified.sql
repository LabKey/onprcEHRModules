SELECT

  t.subjectId as Id,
  t.marker as allele,
  null as shortName,
  sum(t.totalTests) as totalTests,
  t.result,
  GROUP_CONCAT(distinct t.assaytype) as type

FROM geneticscore.mhc_data t
GROUP BY t.subjectid, t.marker, t.result
