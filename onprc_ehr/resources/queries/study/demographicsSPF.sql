SELECT
  f.id,
  group_concat(f.value, chr(10)) as status

FROM study.flags f
WHERE f.enddateTimeCoalesced >= now() AND f.category = 'SPF'
GROUP BY f.id
