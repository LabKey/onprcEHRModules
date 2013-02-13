SELECT
  t1.id,
  t1.year,
  t1.monthname,
  t1.monthnum,
  t1.day,

  group_concat(t1.value, ', ') as value,

FROM (

SELECT
  t.id,
  t.date,
  'Menses' as category,
  'M' as value,

  convert(year(t.date), integer) as year,
  monthname(t.date) AS monthname,
  convert(month(t.date), integer) AS monthnum,
  convert(dayofmonth(t.date), integer) as day,

FROM study."Clinical Observations" t
WHERE t.category = 'Menses'

UNION ALL

SELECT
  t.id,
  t.date,
  'Delivery' as category,
  'D' as value,

  convert(year(t.date), integer) as year,
  monthname(t.date) AS monthname,
  convert(month(t.date), integer) AS monthnum,
  convert(dayofmonth(t.date), integer) as day,

FROM study.delivery t

UNION ALL

SELECT
  t.id,
  t.date,
  'Pregnancies' as category,
  'P' as value,

  convert(year(t.date), integer) as year,
  monthname(t.date) AS monthname,
  convert(month(t.date), integer) AS monthnum,
  convert(dayofmonth(t.date), integer) as day,

FROM study.pregnancyconfirmation t

UNION ALL

SELECT
  t.id,
  t.date,
  'Matings' as category,
  'Mating' as value,

  convert(year(t.date), integer) as year,
  monthname(t.date) AS monthname,
  convert(month(t.date), integer) AS monthnum,
  convert(dayofmonth(t.date), integer) as day,

FROM study.matings t

) t1

GROUP BY t1.year, t1.monthname, t1.monthnum, t1.day, t1.id
PIVOT value BY day