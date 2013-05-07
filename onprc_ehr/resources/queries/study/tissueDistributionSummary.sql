SELECT
  year(t.date) as year,
  count(t.*) as totalSamples,
  count(distinct t.Id) as distinctAnimals,

FROM study.tissueDistribution t

GROUP BY year(t.date)