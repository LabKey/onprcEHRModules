SELECT
  f1.Id,
  group_concat(f1.flag, chr(10)) as flags

FROM (
SELECT
  f.Id,
  CASE
    WHEN f.value is null THEN null
    WHEN f.category IS NULL THEN f.value
    ELSE cast((CAST(f.category as varchar(100)) || CAST(': ' as varchar(2)) || CAST(f.value as varchar(100))) as varchar(202))
  END as flag

FROM study.flags f
WHERE f.isActive = true

) f1

GROUP BY f1.Id