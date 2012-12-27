SELECT
f.id,
f.category,
group_concat(f.flag, chr(10)) as valueField

FROM study.flags f

WHERE f.enddate IS NULL and category is not null

GROUP BY f.id, f.date, f.category

PIVOT valueField by category

