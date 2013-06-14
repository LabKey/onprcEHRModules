SELECT
  s.Id,
  min(s.date) as minDate,
  max(s.date) as maxDate,

  count(s.Id) as totalCodes,
  group_concat(s.text) as codes

FROM (

SELECT
  s.Id,
  s.date,
  s.code,
  s.code.meaning as meaning,
  (s.code.meaning || ' (' || cast(dayofmonth(s.date) as varchar) || '-' || cast(month(s.date) as varchar) || '-' || cast(year(s.date) as varchar) || ')') as text

FROM study.encountersWithSnomed s

WHERE s.code IN ('F-31040', 'F-31030', 'F-31020') AND timestampdiff('SQL_TSI_DAY', s.date, curdate()) < 150

) s

GROUP BY s.Id