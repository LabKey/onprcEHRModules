SELECT

d.category,

count(distinct d.id) as totalAnimals,

FROM study.demographicsPaired d

GROUP BY d.category