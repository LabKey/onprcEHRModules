SELECT
  f.id,
  group_concat(f.value, chr(10)) as condition

FROM study.flags f
WHERE f.enddateCoalesced >= curdate() AND f.category = 'Condition'
GROUP BY f.id
