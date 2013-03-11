SELECT
  year(c.date) as year,
  month(c.date) as monthNum,
  monthname(c.date) as month,
  c.eventType,
  count(*) as total

FROM study.clinicalEvents c
GROUP BY year(c.date), month(c.date), monthname(c.date), c.eventType