SELECT
  year(c.date) as year,
  c.eventType,
  count(*) as total

FROM study.clinicalEvents c
GROUP BY year(c.date), c.eventType