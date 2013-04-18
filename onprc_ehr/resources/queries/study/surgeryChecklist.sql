SELECT
  d.id,
  d.species,
  d.gender,
  d.id.activeAssignments.projects,
  d.id.activeAssignments.investigators,
  d.id.age.ageInYears,
  h.result as PLT,
  h2.result as HCT,
FROM study.demographics d
LEFT JOIN (
  SELECT hr.id, hr.result
  FROM study.hematologyResults hr
  WHERE hr.testId = 'PLT' and hr.result IS NOT NULL and hr.date = (SELECT max(date) FROM study.hematologyResults hr2 WHERE hr2.id = hr.id)
) h ON (d.id = h.id)

LEFT JOIN (
  SELECT hr.id, hr.result
  FROM study.hematologyResults hr
  WHERE hr.testId = 'HCT' and hr.result IS NOT NULL and hr.date = (SELECT max(date) FROM study.hematologyResults hr2 WHERE hr2.id = hr.id)
) h2 ON (d.id = h2.id)