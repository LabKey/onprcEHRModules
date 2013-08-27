SELECT
  p.Id,
  count(CASE WHEN p.category = 'Clinical' THEN 1 ELSE NULL END) as totalClinicalCases,
  count(CASE WHEN p.category = 'Behavior' THEN 1 ELSE NULL END) as totalBehaviorCases,
  count(CASE WHEN p.category = 'Surgery' THEN 1 ELSE NULL END) as totalSurgeryCases,
  count(*) as totalCases
FROM study.cases p
WHERE timestampdiff('SQL_TSI_DAY', p.date, now()) < 180
GROUP BY p.id