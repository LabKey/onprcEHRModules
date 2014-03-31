SELECT
  c.Id,
  c.date,
  c.enddate,
  c.reviewdate,
  c.category,
  c.performedby,
  c.description,
  c.problemCategories,
  c.remark,
  c.mostrecentP2,
  c.isActive,

FROM study.cases c
WHERE c.isActive = true AND c.category = 'Clinical'

UNION ALL

SELECT
  d.Id,
  d.date,

  null as enddate,
  null as reviewdate,
  null as category,
  null as performedby,
  null as description,
  null as problemCategories,
  null as remark,
  null as mostrecentP2,
  null as isActive,

FROM study.demographicsCurrentLocation d
WHERE d.area = 'Hospital' AND d.Id.activecases.categories NOT LIKE 'Clinical'