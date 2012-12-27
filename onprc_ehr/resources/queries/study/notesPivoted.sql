SELECT
f.id,
f.category,
group_concat(f.remark, chr(10)) as valueField

FROM study.notes f

WHERE f.enddate IS NULL and category is not null

GROUP BY f.id, f.category

PIVOT valueField by category

