SELECT
  o.Id,
  max(o.date) as lastDate

FROM study.	clinical_observations o
WHERE o.category = 'Menses'
GROUP BY o.Id