SELECT
  c.Id,
  c.problemCategories,
  count(c.Id) as totalCases

FROM study.cases c

--2 years
WHERE timestampdiff('SQL_TSI_DAY', c.date, now()) <= (365 * 2)
AND c.category = 'Clinical'

GROUP BY c.Id, c.problemCategories