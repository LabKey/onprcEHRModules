SELECT
  o.Id,
  o.date,
  o.category,
  o.area,
  o.observation,
  o.remark,
  o.caseid,
  c.category as caseCategory

FROM study.clinical_observations o
JOIN study.cases c ON (c.objectid = o.caseid)