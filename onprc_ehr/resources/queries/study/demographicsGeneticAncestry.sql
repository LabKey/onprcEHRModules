SELECT
d.Id,
group_concat(distinct d.result) as geneticAncestry

FROM study.geneticAncestry d
WHERE d.isActive = true
GROUP BY d.Id