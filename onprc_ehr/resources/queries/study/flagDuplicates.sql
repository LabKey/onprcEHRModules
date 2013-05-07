SELECT
  f.id,
  f.flag,
  group_concat(f.value, chr(10)) as values,
  count(f.value) as totalFlags

FROM study.flags f
JOIN ehr_lookups.flag_categories fc ON (f.flag = fc.category)
WHERE fc.enforceUnique = true and f.enddateTimeCoalesced >= now()
GROUP BY f.id, f.flag
HAVING count(*) > 1
