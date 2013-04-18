SELECT
  d.Id,
  coalesce(t.viralStatus, 'Not SPF') as viralStatus,
  t.total

FROM study.demographics d
LEFT JOIN (
  SELECT
    f.Id,
    group_concat(distinct f.value, chr(10)) as viralStatus,
    count(distinct f.value) as total

  FROM study.flags f
  WHERE f.enddateTimeCoalesced >= now() AND f.flag = 'SPF' and f.id.dataset.demographics.calculated_status = 'Alive'
  --TODO: this is a hack
  AND f.value not like '%Candidate%'

  GROUP BY f.id
) t ON (d.id = t.id)