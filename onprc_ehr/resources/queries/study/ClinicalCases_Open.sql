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
  c.mostRecentP2,
  c.isActive,
  c.assignedvet,
  c.mostRecentCeg_Plan

FROM study.cases c
WHERE c.isOpen = true AND c.category = 'Clinical'