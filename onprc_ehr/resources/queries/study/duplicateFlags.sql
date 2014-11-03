SELECT
  f.Id,
  f.flag,
  count(*) as total,
  min(f.date) as minDate,
  max(f.date) as maxDate,
  min(f.created) as minDateCreated,
  max(f.created) as maxDateCreated
FROM study.flags f
WHERE f.isActive = true
GROUP BY f.Id, f.flag